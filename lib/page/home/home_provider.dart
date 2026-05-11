import 'dart:async' show unawaited;

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_logger.dart';
import '../../core/auth_prefs.dart';
import '../../core/dashboard_prefs.dart';
import '../../core/profile_initials.dart';
import '../reporting/reporting_sync_service.dart';
import 'home_repository.dart';
import 'home_residence_sync.dart';
import 'home_state.dart';

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  Future<void> onAppear() async {
    await _hydrateFromPrefs();
    unawaited(ref.read(reportingSyncServiceProvider).processQueue());
    await refreshFromRemote();
  }

  Future<void> refreshFromRemote() async {
    state = state.copyWith(refreshing: true, loadError: null, triggerNoRoleDialog: false);
    try {
      final repo = ref.read(homeRepositoryProvider);
      final roles = await AuthPrefs.readUserRolesJson();
      final before = await DashboardPrefs.loadSnapshot();
      final body = await repo.fetchResidences();
      await syncResidencesFromResponse(
        body: body,
        rolesJson: roles ?? '',
        alreadyHadResidenceName: before.hasResidence,
        currentResidenceId: before.residenceId,
      );
      final after = await DashboardPrefs.loadSnapshot();
      if (!after.hasResidence) {
        state = state.copyWith(refreshing: false, triggerNoRoleDialog: true);
        return;
      }
      if (after.securityUuid.isNotEmpty) {
        final raw = await repo.fetchGuardPinJson(after.securityUuid);
        final trimmed = repo.trimGuardPinPayload(raw);
        await DashboardPrefs.setSecurityJson(trimmed);
      }
      if (after.residenceId.isNotEmpty) {
        final typesJson = await repo.fetchVisitorTypesJson(after.residenceId);
        await DashboardPrefs.setVisitorTypesJson(typesJson);
      }
      await _hydrateFromPrefs();
      unawaited(ref.read(reportingSyncServiceProvider).processQueue());
      state = state.copyWith(refreshing: false);
    } on DioException catch (e, st) {
      AppLog.error('Dashboard refresh failed', tag: 'Home', error: e, stackTrace: st);
      state = state.copyWith(refreshing: false, loadError: _dioMessage(e));
    } catch (e, st) {
      AppLog.error('Dashboard refresh failed', tag: 'Home', error: e, stackTrace: st);
      state = state.copyWith(refreshing: false, loadError: 'Something went wrong');
    }
  }

  void acknowledgeNoRoleDialog() {
    state = state.copyWith(triggerNoRoleDialog: false);
  }

  /// After user picks a site on the select-site screen: reload prefs + guard pin / visitor types / residence sync.
  Future<void> onSiteChanged() async {
    await _hydrateFromPrefs();
    await refreshFromRemote();
  }

  Future<void> _hydrateFromPrefs() async {
    final snap = await DashboardPrefs.loadSnapshot();
    final name = (await AuthPrefs.readUserName()) ?? '';
    final email = (await AuthPrefs.readUserEmail()) ?? '';
    state = state.copyWith(
      residenceTitle: snap.hasResidence ? snap.residenceName : 'kipleSafe',
      userName: name,
      userEmail: email,
      profileInitial: profileInitials(name),
      attendanceEnabled: snap.attendance,
      visitorEnabled: snap.visitor,
      reportEnabled: snap.report,
      bookingEnabled: snap.booking,
      intercomEnabled: snap.intercom,
      qrEnabled: snap.qr,
    );
  }
}

String _dioMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] is String) return data['message']! as String;
  return e.message ?? 'Network error';
}
