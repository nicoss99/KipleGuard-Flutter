import 'dart:async' show unawaited;

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_logger.dart';
import '../../core/auth_prefs.dart';
import '../../core/dashboard_prefs.dart';
import '../../core/profile_initials.dart';
import '../../core/site_scope_invalidation.dart';
import '../reporting/reporting_sync_service.dart';
import '../select_site/residence_choice.dart';
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
      await _refreshSiteScopedData(repo);
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

  /// Updates dashboard UI, clears feature caches, then refreshes site-scoped APIs.
  Future<void> applySiteSelection(
    ResidenceChoice choice, {
    required String previousResidenceId,
    required String previousSecurityUuid,
  }) async {
    _applyChoiceToState(choice);
    invalidateSiteScopedProviders(ref);
    await _refreshSiteDataAfterSelection(
      previousResidenceId: previousResidenceId,
      previousSecurityUuid: previousSecurityUuid,
    );
  }

  void _applyChoiceToState(ResidenceChoice c) {
    state = state.copyWith(
      residenceTitle: c.name,
      attendanceEnabled: c.attendance == 'true',
      visitorEnabled: c.visitors == 'true',
      reportEnabled: c.reporting == 'true',
      bookingEnabled: c.booking == 'true',
      intercomEnabled: c.intercom == 'true',
      qrEnabled: c.qr == 'true',
      loadError: null,
    );
  }

  Future<void> _refreshSiteDataAfterSelection({
    required String previousResidenceId,
    required String previousSecurityUuid,
  }) async {
    try {
      final repo = ref.read(homeRepositoryProvider);
      await _refreshSiteScopedData(
        repo,
        previousResidenceId: previousResidenceId,
        previousSecurityUuid: previousSecurityUuid,
      );
      unawaited(ref.read(reportingSyncServiceProvider).processQueue());
    } on DioException catch (e, st) {
      AppLog.error('Site background sync failed', tag: 'Home', error: e, stackTrace: st);
    } catch (e, st) {
      AppLog.error('Site background sync failed', tag: 'Home', error: e, stackTrace: st);
    }
  }

  /// Guard PIN + visitor types when site/security actually changed.
  Future<void> _refreshSiteScopedData(
    HomeRepository repo, {
    String? previousResidenceId,
    String? previousSecurityUuid,
  }) async {
    final snap = await DashboardPrefs.loadSnapshot();
    final tasks = <Future<void>>[];
    final residenceId = snap.residenceId;
    final securityUuid = snap.securityUuid;

    final residenceChanged =
        residenceId.isNotEmpty && residenceId != (previousResidenceId ?? '');
    final securityChanged =
        securityUuid.isNotEmpty && securityUuid != (previousSecurityUuid ?? '');

    if (residenceChanged) {
      tasks.add(_loadVisitorTypes(repo, residenceId));
    }
    if (securityChanged) {
      tasks.add(_loadGuardPin(repo, securityUuid));
    }
    if (tasks.isNotEmpty) await Future.wait(tasks);
  }

  Future<void> _loadGuardPin(HomeRepository repo, String securityUuid) async {
    final raw = await repo.fetchGuardPinJson(securityUuid);
    await DashboardPrefs.setSecurityJson(repo.trimGuardPinPayload(raw));
  }

  Future<void> _loadVisitorTypes(HomeRepository repo, String residenceId) async {
    final typesJson = await repo.fetchVisitorTypesJson(residenceId);
    await DashboardPrefs.setVisitorTypesJson(typesJson);
  }

  void acknowledgeNoRoleDialog() {
    state = state.copyWith(triggerNoRoleDialog: false);
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
