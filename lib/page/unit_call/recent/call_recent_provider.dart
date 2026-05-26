import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/app_logger.dart';
import '../../../core/connectivity/connectivity_refresh.dart';
import '../../../core/dashboard_prefs.dart';
import '../../../core/api_error_message.dart';
import '../../../core/network/dio_network.dart';
import '../../../core/offline/offline_messages.dart';
import '../guard_unit_call_repository.dart';
import '../unit_call_strings.dart';
import 'call_recent_models.dart';
import 'call_recent_parser.dart';
import 'call_recent_phone_resolve.dart';
import 'call_recent_repository.dart';
import 'call_recent_state.dart';

final callRecentProvider = NotifierProvider<CallRecentNotifier, CallRecentState>(CallRecentNotifier.new);

class CallRecentNotifier extends Notifier<CallRecentState> {
  @override
  CallRecentState build() => const CallRecentState();

  Future<void> load() async {
    state = const CallRecentState();
    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) {
      state = state.copyWith(loading: false, error: UnitCallStrings.noResidence);
      return;
    }
    state = state.copyWith(
      residenceName: snap.residenceName,
      residenceUuid: snap.residenceId,
      clearError: true,
    );

    await _applyCached(snap.residenceId);
    if (!await isDeviceOnline(ref)) {
      state = state.copyWith(
        loading: false,
        error: state.rows.isEmpty ? offlineNoCachedDataMessage() : null,
        clearError: state.rows.isNotEmpty,
      );
      return;
    }
    await refreshFromNetwork();
  }

  Future<void> _applyCached(String residenceId) async {
    final cached = await ref.read(callRecentRepositoryProvider).loadCached(residenceId);
    if (cached == null || cached.resource.isEmpty) return;
    final rows = await enrichCallHistoryWithPhones(
      ref,
      residenceId,
      parseCallHistoryResources(cached.resource),
    );
    state = state.copyWith(
      loading: false,
      rows: rows,
      fromCache: true,
      cacheSavedAt: cached.savedAt,
    );
  }

  Future<void> refreshFromNetwork() async {
    final id = state.residenceUuid;
    if (id.isEmpty) return;

    if (!await isDeviceOnline(ref)) {
      await _applyCached(id);
      state = state.copyWith(
        refreshing: false,
        loading: false,
        clearError: state.rows.isNotEmpty,
        error: state.rows.isEmpty ? offlineNoCachedDataMessage() : null,
      );
      return;
    }

    state = state.copyWith(refreshing: true, clearError: true);
    try {
      final repo = ref.read(callRecentRepositoryProvider);
      final raw = await repo.fetchHistory(id);
      final rows = await enrichCallHistoryWithPhones(
        ref,
        id,
        parseCallHistoryResources(raw),
      );
      state = state.copyWith(
        refreshing: false,
        loading: false,
        rows: rows,
        clearCacheMeta: true,
      );
    } on DioException catch (e, st) {
      AppLog.error('Call history failed', tag: 'CallRecent', error: e, stackTrace: st);
      if (isNetworkError(e)) {
        await _applyCached(id);
        if (state.rows.isNotEmpty) {
          state = state.copyWith(refreshing: false, loading: false, clearError: true);
          return;
        }
      }
      state = state.copyWith(
        refreshing: false,
        loading: false,
        error: userFacingErrorMessage(e),
      );
    } catch (e, st) {
      AppLog.error('Call history failed', tag: 'CallRecent', error: e, stackTrace: st);
      state = state.copyWith(
        refreshing: false,
        loading: false,
        error: userFacingErrorMessage(e),
      );
    }
  }

  void setSearch(String q) {
    state = state.copyWith(searchQuery: q);
  }

  Future<String?> phoneForRow(CallHistoryRow row) async {
    final cached = row.receiverPhone.trim();
    if (cached.length > 5) return cached;

    final residenceId = state.residenceUuid;
    if (residenceId.isEmpty || row.unitId.isEmpty) return null;
    try {
      final hosts = await ref.read(guardUnitCallRepositoryProvider).fetchHosts(
            residenceId,
            unitUuid: row.unitId,
          );
      return matchCallRecentHostPhone(hosts, row);
    } catch (_) {
      return null;
    }
  }
}
