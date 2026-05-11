import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/api_error_message.dart';
import '../../core/app_logger.dart';
import '../../core/dashboard_prefs.dart';
import 'attendance_pin_validation.dart';
import 'attendance_repository.dart';
import 'attendance_state.dart';
import 'attendance_strings.dart';

final attendanceProvider =
    NotifierProvider<AttendanceNotifier, AttendanceState>(
      AttendanceNotifier.new,
    );

class AttendanceNotifier extends Notifier<AttendanceState> {
  @override
  AttendanceState build() => AttendanceState(selectedDay: DateTime.now());

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
    if (snap.residenceId.isEmpty) {
      state = state.copyWith(loading: false, error: 'No residence selected');
      return;
    }
    if (showLoading) state = state.copyWith(loading: true, clearError: true);
    try {
      final rows = await ref
          .read(attendanceRepositoryProvider)
          .fetchAttendanceForDay(
            residenceUuid: snap.residenceId,
            dayLocal: state.selectedDay,
          );
      state = state.copyWith(records: rows, loading: false);
    } catch (e, st) {
      AppLog.error(
        'Attendance list failed',
        tag: 'Attendance',
        error: e,
        stackTrace: st,
      );
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
    }
  }

  /// Member PIN: Android `guardPinAPI` (GET `data/kg_guards`) when [DashboardSnapshot.securityUuid]
  /// is set, then match like `AttendanceActivity.checkGuardPin`; then `filterAttendanceListAPI`;
  /// then camera + `submit_checkin` / `submit_checkout`.
  Future<String?> verifyPinAndPrepareShift({
    required String pin6,
    required AttendanceShiftFlow flow,
  }) async {
    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) {
      return AttendanceStrings.missingSecurityProfile;
    }

    var securityJson = snap.securityJson.trim();
    final repo = ref.read(attendanceRepositoryProvider);

    if (snap.securityUuid.isNotEmpty) {
      try {
        final guards = await repo.fetchGuardsForPinValidation(snap.securityUuid);
        securityJson = jsonEncode(<String, dynamic>{'resource': guards});
        await DashboardPrefs.setSecurityJson(securityJson);
      } catch (e, st) {
        AppLog.error(
          'Guard PIN API failed',
          tag: 'Attendance',
          error: e,
          stackTrace: st,
        );
        return apiErrorMessage(e);
      }
    } else if (securityJson.isEmpty) {
      return AttendanceStrings.missingSecurityProfile;
    }

    final match = matchGuardForResidence(
      securityJson: securityJson,
      residenceUuid: snap.residenceId,
      pin6: pin6,
    );
    if (match == null) return AttendanceStrings.invalidPin;

    try {
      final openRows = await repo.filterAttendanceListApi(match.guardUuid);
      if (flow == AttendanceShiftFlow.startShift && openRows.isNotEmpty) {
        return AttendanceStrings.shiftAlreadyStarted;
      }
      if (flow == AttendanceShiftFlow.endShift && openRows.isEmpty) {
        return AttendanceStrings.shiftAlreadyEnded;
      }
    } catch (e, st) {
      AppLog.error(
        'Filter attendance failed',
        tag: 'Attendance',
        error: e,
        stackTrace: st,
      );
      return apiErrorMessage(e);
    }

    state = state.copyWith(
      shiftFlow: flow,
      guardUuid: match.guardUuid,
      companyUuid: match.companyUuid,
    );
    return null;
  }

  void clearShiftFlow() {
    state = state.copyWith(
      shiftFlow: AttendanceShiftFlow.none,
      guardUuid: '',
      companyUuid: '',
    );
  }

  Future<String?> capturePhotoAndSubmit() async {
    final cam = await Permission.camera.request();
    if (!cam.isGranted) {
      clearShiftFlow();
      return 'Camera permission denied';
    }

    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );
    if (x == null) {
      clearShiftFlow();
      state = state.copyWith(loading: false);
      return null;
    }

    final flow = state.shiftFlow;
    final guardUuid = state.guardUuid;
    final companyUuid = state.companyUuid;
    if (flow == AttendanceShiftFlow.none || guardUuid.isEmpty) {
      clearShiftFlow();
      return 'Session expired';
    }

    final snap = await DashboardPrefs.loadSnapshot();
    state = state.copyWith(loading: true, clearError: true);
    try {
      final pos = await _tryPosition();
      final url = await ref
          .read(attendanceRepositoryProvider)
          .uploadAttendancePhoto(File(x.path));
      final repo = ref.read(attendanceRepositoryProvider);
      if (flow == AttendanceShiftFlow.startShift) {
        await repo.submitCheckIn(
          residenceUuid: snap.residenceId,
          guardUuid: guardUuid,
          companyUuid: companyUuid,
          lat: pos.lat,
          lng: pos.lng,
          photoUrl: url,
        );
      } else {
        await repo.submitCheckOut(
          guardUuid: guardUuid,
          lat: pos.lat,
          lng: pos.lng,
          photoUrl: url,
        );
      }
      clearShiftFlow();
      await refreshRecords(showLoading: false);
      state = state.copyWith(loading: false);
      return null;
    } catch (e, st) {
      AppLog.error(
        'Attendance submit failed',
        tag: 'Attendance',
        error: e,
        stackTrace: st,
      );
      clearShiftFlow();
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
      return apiErrorMessage(e);
    }
  }

  Future<({double lat, double lng})> _tryPosition() async {
    final loc = await Permission.location.request();
    if (!loc.isGranted) return (lat: 0.0, lng: 0.0);
    try {
      final p = await Geolocator.getCurrentPosition();
      return (lat: p.latitude, lng: p.longitude);
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return (lat: last.latitude, lng: last.longitude);
      return (lat: 0.0, lng: 0.0);
    }
  }
}
