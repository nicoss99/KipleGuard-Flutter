import 'dart:async' show unawaited;

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api_error_message.dart';
import '../../core/app_logger.dart';
import '../../core/auth_prefs.dart';
import '../../core/cache/guard_detail_cache.dart';
import '../../core/dashboard_prefs.dart';
import '../../core/profile_initials.dart';
import '../../core/residence_prefs.dart';
import '../../core/site_scope_invalidation.dart';
import '../auth/guard_repository.dart';
import '../auth/guard_models.dart';
import '../reporting/reporting_sync_service.dart';
import '../select_site/residence_choice.dart';
import '../../core/api/contracts/legacy_guard_data_repository.dart';
import 'home_repository.dart';
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
      await _refreshGuardProfile();
      final residences = await ref.read(guardRepositoryProvider).fetchResidences();
      if (residences.isEmpty) {
        state = state.copyWith(refreshing: false, triggerNoRoleDialog: true);
        return;
      }
      final savedUuid = await ResidencePrefs.readResidenceUuid();
      if (savedUuid == null || savedUuid.isEmpty) {
        await ResidencePrefs.applyDefaultFromResidences(residences);
      } else {
        for (final r in residences) {
          if (r.uuid == savedUuid) {
            await DashboardPrefs.applySecurityCompanyFromResidenceApi(
              r.securityCompanyUuid,
            );
            break;
          }
        }
      }
      final after = await DashboardPrefs.loadSnapshot();
      if (!after.hasResidence) {
        state = state.copyWith(refreshing: false, triggerNoRoleDialog: true);
        return;
      }
      await _refreshSiteScopedData(
        ref.read(homeRepositoryProvider),
        alwaysReloadGuardPin: false,
      );
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
    required String previousSecurityUuid,
  }) async {
    _applyChoiceToState(choice);
    invalidateSiteScopedProviders(ref);
    await _refreshSiteDataAfterSelection(previousSecurityUuid: previousSecurityUuid);
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
    required String previousSecurityUuid,
  }) async {
    try {
      await _refreshGuardProfile();
      final repo = ref.read(homeRepositoryProvider);
      await _refreshSiteScopedData(
        repo,
        previousSecurityUuid: previousSecurityUuid,
        alwaysReloadGuardPin: true,
      );
      unawaited(ref.read(reportingSyncServiceProvider).processQueue());
    } on DioException catch (e, st) {
      AppLog.error('Site background sync failed', tag: 'Home', error: e, stackTrace: st);
    } catch (e, st) {
      AppLog.error('Site background sync failed', tag: 'Home', error: e, stackTrace: st);
    }
  }

  /// Loads `securityJson` for PIN flows (attendance, reporting) when needed.
  ///
  /// Android stores `DBOthers.securityJson` after guard-pin API; we refetch when
  /// the security company changes, JSON is missing, or [alwaysReloadGuardPin]
  /// (e.g. user picked another site — refresh guard↔residence links).
  Future<void> _refreshSiteScopedData(
    LegacyGuardDataRepository repo, {
    String? previousSecurityUuid,
    bool alwaysReloadGuardPin = false,
  }) async {
    final snap = await DashboardPrefs.loadSnapshot();
    final securityUuid = snap.securityUuid;
    if (securityUuid.isEmpty) return;

    final prev = previousSecurityUuid ?? '';
    final companyChanged = securityUuid != prev;
    final jsonMissing = snap.securityJson.trim().isEmpty;
    final shouldLoad =
        alwaysReloadGuardPin || companyChanged || jsonMissing;
    if (!shouldLoad) return;

    await _loadGuardPin(repo, securityUuid);
  }

  Future<void> _loadGuardPin(LegacyGuardDataRepository repo, String securityUuid) async {
    final raw = await repo.fetchGuardPinJson(securityUuid);
    await DashboardPrefs.setSecurityJson(repo.trimGuardPinPayload(raw));
  }

  void acknowledgeNoRoleDialog() {
    state = state.copyWith(triggerNoRoleDialog: false);
  }

  /// Reloads dashboard greeting from prefs (after profile `/me` refresh).
  Future<void> reloadUserFromPrefs() => _hydrateFromPrefs();

  void _applyUserFromGuard(GuardProfile guard) {
    state = state.copyWith(
      userName: guard.name,
      userEmail: guard.email,
      profileInitial: profileInitials(guard.name),
    );
  }

  Future<void> _refreshGuardProfile() async {
    try {
      final me = await ref.read(guardRepositoryProvider).fetchMe();
      await GuardDetailCache.saveGuardProfile(
        guard: me.guard,
        residences: me.residences,
      );
      _applyUserFromGuard(me.guard);
    } catch (e, st) {
      AppLog.error('Guard profile refresh failed', tag: 'Home', error: e, stackTrace: st);
    }
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

String _dioMessage(DioException e) => userFacingErrorMessage(e);
