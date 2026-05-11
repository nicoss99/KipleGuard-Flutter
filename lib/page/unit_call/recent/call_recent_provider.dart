import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/app_logger.dart';
import '../../../core/dashboard_prefs.dart';
import '../unit_call_strings.dart';
import 'call_recent_parser.dart';
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

    final repo = ref.read(callRecentRepositoryProvider);
    final cached = await repo.loadCached(snap.residenceId);
    if (cached.isNotEmpty) {
      state = state.copyWith(
        loading: false,
        rows: parseCallHistoryResources(cached),
      );
    }

    await refreshFromNetwork();
  }

  Future<void> refreshFromNetwork() async {
    final id = state.residenceUuid;
    if (id.isEmpty) return;
    state = state.copyWith(refreshing: true, clearError: true);
    try {
      final repo = ref.read(callRecentRepositoryProvider);
      final raw = await repo.fetchHistory(id);
      state = state.copyWith(
        refreshing: false,
        loading: false,
        rows: parseCallHistoryResources(raw),
      );
    } on DioException catch (e, st) {
      AppLog.error('Call history failed', tag: 'CallRecent', error: e, stackTrace: st);
      state = state.copyWith(
        refreshing: false,
        loading: false,
        error: e.message ?? 'Network error',
      );
    } catch (e, st) {
      AppLog.error('Call history failed', tag: 'CallRecent', error: e, stackTrace: st);
      state = state.copyWith(refreshing: false, loading: false, error: 'Something went wrong');
    }
  }

  void setSearch(String q) {
    state = state.copyWith(searchQuery: q);
  }
}
