import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/api_error_message.dart';
import '../../core/offline/offline_messages.dart';
import '../../core/app_logger.dart';
import '../../core/cache/guard_list_cache.dart';
import '../../core/connectivity/connectivity_refresh.dart';
import '../../core/network/dio_network.dart';
import '../../core/auth_prefs.dart';
import '../../core/dashboard_prefs.dart' show DashboardPrefs, DashboardSnapshot;
import '../auth/guard_attendance_repository.dart';
import 'attendance_state.dart';
import 'attendance_strings.dart';

final attendanceProvider =
    NotifierProvider<AttendanceNotifier, AttendanceState>(
      AttendanceNotifier.new,
    );

class AttendanceNotifier extends Notifier<AttendanceState> {
  @override
  AttendanceState build() => AttendanceState(selectedDay: DateTime.now());

  static bool _hasResidenceId(DashboardSnapshot snap) =>
      snap.residenceId.trim().isNotEmpty;

  void _logResidenceValidation(
    String step, {
    required DashboardSnapshot snap,
    AttendanceShiftFlow? flow,
    String? blockedBy,
  }) {
    AppLog.debug(
      'residence validation [$step]',
      tag: 'Attendance',
      data: {
        'flow': flow?.name,
        'residenceId': snap.residenceId.isEmpty ? '(empty)' : snap.residenceId,
        'residenceIdLength': snap.residenceId.length,
        'hasResidenceId': _hasResidenceId(snap),
        'securityJsonLength': snap.securityJson.length,
        'blockedBy': blockedBy,
      },
    );
  }

  Future<void> setTab(int index) async {
    state = state.copyWith(tabIndex: index);
    if (index == 1) await refreshRecords();
  }

  Future<void> setSelectedDay(DateTime day) async {
    state = state.copyWith(selectedDay: DateTime(day.year, day.month, day.day));
    if (state.tabIndex == 1) await refreshRecords();
  }

  Future<void> refreshRecords({bool showLoading = true}) async {
    final snap = await DashboardPrefs.loadSnapshot();
    if (!_hasResidenceId(snap)) {
      _logResidenceValidation(
        'refreshRecords',
        snap: snap,
        blockedBy: AttendanceStrings.noResidenceSelected,
      );
      state = state.copyWith(
        loading: false,
        error: AttendanceStrings.noResidenceSelected,
      );
      return;
    }
    _logResidenceValidation('refreshRecords', snap: snap);
    if (showLoading) state = state.copyWith(loading: true, clearError: true);

    if (!await isDeviceOnline(ref)) {
      final cached = await GuardListCache.readAttendance(
        residenceUuid: snap.residenceId,
        day: state.selectedDay,
      );
      if (cached != null) {
        state = state.copyWith(
          records: cached.records,
          loading: false,
          fromCache: true,
          cacheSavedAt: cached.savedAt,
        );
        return;
      }
      state = state.copyWith(
        loading: false,
        error: offlineNoCachedDataMessage(),
      );
      return;
    }

    try {
      final repo = ref.read(guardAttendanceRepositoryProvider);
      final guardName = (await AuthPrefs.readUserName()) ?? '';
      final list = await repo.fetchAttendance(
        residenceUuid: snap.residenceId,
        fromDay: state.selectedDay,
        toDay: state.selectedDay,
      );
      final records = repo.toRecordRows(list, guardName: guardName);
      await GuardListCache.saveAttendance(
        residenceUuid: snap.residenceId,
        day: state.selectedDay,
        records: records,
      );
      state = state.copyWith(
        records: records,
        loading: false,
        clearCacheMeta: true,
      );
    } on DioException catch (e, st) {
      AppLog.error('Attendance list failed', tag: 'Attendance', error: e, stackTrace: st);
      if (isNetworkError(e)) {
        final cached = await GuardListCache.readAttendance(
          residenceUuid: snap.residenceId,
          day: state.selectedDay,
        );
        if (cached != null) {
          state = state.copyWith(
            records: cached.records,
            loading: false,
            fromCache: true,
            cacheSavedAt: cached.savedAt,
          );
          return;
        }
      }
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
    } catch (e, st) {
      AppLog.error('Attendance list failed', tag: 'Attendance', error: e, stackTrace: st);
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
    }
  }

  Future<String?> prepareShift(
    AttendanceShiftFlow flow, {
    required String guardUuid,
  }) async {
    final snap = await DashboardPrefs.loadSnapshot();
    if (!_hasResidenceId(snap)) {
      _logResidenceValidation(
        'prepareShift',
        snap: snap,
        flow: flow,
        blockedBy: AttendanceStrings.noResidenceSelected,
      );
      return AttendanceStrings.noResidenceSelected;
    }
    _logResidenceValidation('prepareShift', snap: snap, flow: flow);

    final repo = ref.read(guardAttendanceRepositoryProvider);
    try {
      final hasOpen = await repo.hasOpenShiftForGuard(snap.residenceId, guardUuid);
      if (flow == AttendanceShiftFlow.startShift && hasOpen) {
        return AttendanceStrings.shiftAlreadyStarted;
      }
      if (flow == AttendanceShiftFlow.endShift && !hasOpen) {
        return AttendanceStrings.shiftAlreadyEnded;
      }
      state = state.copyWith(shiftFlow: flow);
      return null;
    } catch (e, st) {
      AppLog.error('Attendance shift check failed', tag: 'Attendance', error: e, stackTrace: st);
      return apiErrorMessage(e);
    }
  }

  void clearShiftFlow() {
    state = state.copyWith(shiftFlow: AttendanceShiftFlow.none);
  }

  void clearError() {
    if (state.error != null) state = state.copyWith(clearError: true);
  }

  Future<String?> capturePhotoAndSubmit() async {
    final flow = state.shiftFlow;
    if (flow == AttendanceShiftFlow.none) return 'Session expired';

    final cam = await Permission.camera.request();
    if (!cam.isGranted) {
      clearShiftFlow();
      return 'Camera permission denied';
    }

    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.camera, imageQuality: 60);
    if (x == null) {
      clearShiftFlow();
      return null;
    }

    final snap = await DashboardPrefs.loadSnapshot();
    if (!_hasResidenceId(snap)) {
      _logResidenceValidation(
        'capturePhotoAndSubmit',
        snap: snap,
        flow: flow,
        blockedBy: AttendanceStrings.noResidenceSelected,
      );
      clearShiftFlow();
      return AttendanceStrings.noResidenceSelected;
    }
    _logResidenceValidation('capturePhotoAndSubmit', snap: snap, flow: flow);

    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = ref.read(guardAttendanceRepositoryProvider);
      final file = File(x.path);
      if (flow == AttendanceShiftFlow.startShift) {
        await repo.startShift(residenceUuid: snap.residenceId, selfie: file);
      } else {
        await repo.endShift(residenceUuid: snap.residenceId, selfie: file);
      }
      clearShiftFlow();
      await refreshRecords(showLoading: false);
      state = state.copyWith(loading: false);
      return null;
    } catch (e, st) {
      AppLog.error('Attendance submit failed', tag: 'Attendance', error: e, stackTrace: st);
      clearShiftFlow();
      state = state.copyWith(loading: false);
      return apiErrorMessage(e);
    }
  }
}
