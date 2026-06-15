import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api_error_message.dart';
import '../../core/offline/offline_messages.dart';
import '../../core/cache/guard_list_cache.dart';
import '../../core/connectivity/connectivity_refresh.dart';
import '../../core/dashboard_prefs.dart';
import '../../core/network/dio_network.dart';

import '../auth/guard_visitor_repository.dart';
import '../auth/guard_visitor_status.dart';

import 'visitor_model.dart';
import 'visitor_state.dart';
import 'visitor_tab_status.dart';

final visitorProvider = NotifierProvider<VisitorNotifier, VisitorState>(VisitorNotifier.new);

class VisitorNotifier extends Notifier<VisitorState> {
  @override
  VisitorState build() {
    Future<void>.microtask(_loadInitial);
    return VisitorState(
      selectedDay: DateTime.now(),
      tabIndex: 3,
      items: const [],
      loading: true,
    );
  }

  Future<void> _loadInitial() => _load(
        day: state.selectedDay,
        tab: state.tabIndex,
        search: state.searchActive,
        query: state.searchQuery,
      );

  Future<void> refresh() => _loadInitial();

  void clearError() {
    if (state.error != null) state = state.copyWith(clearError: true);
  }

  Future<void> setDay(DateTime day) => _load(day: day, tab: state.tabIndex, search: false, query: '');

  Future<void> setTab(int tab) =>
      _load(day: state.selectedDay, tab: tab, search: false, query: '', allOvertimeSection: false);

  Future<void> runSearch(String query) =>
      _load(day: state.selectedDay, tab: state.tabIndex, search: true, query: query);

  Future<void> clearSearch() => _load(day: state.selectedDay, tab: state.tabIndex, search: false, query: '');

  Future<void> previousDay() => setDay(state.selectedDay.subtract(const Duration(days: 1)));

  Future<void> nextDay() => setDay(state.selectedDay.add(const Duration(days: 1)));

  Future<void> openAllOvertimeSection() => _load(
        day: state.selectedDay,
        tab: 2,
        search: false,
        query: '',
        allOvertimeSection: true,
      );

  Future<bool> quickAction(VisitorListItem item) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final snap = await DashboardPrefs.loadSnapshot();
      if (snap.residenceId.isEmpty) {
        state = state.copyWith(loading: false, error: 'No residence selected');
        return false;
      }
      final repo = ref.read(guardVisitorRepositoryProvider);
      final visitorId = int.tryParse(item.uuid);
      if (visitorId == null) {
        state = state.copyWith(loading: false, error: 'Invalid visitor');
        return false;
      }
      if (item.visitStatus == GuardVisitorApiStatus.checkedIn ||
          item.latestScanType.toUpperCase() == 'IN') {
        await repo.checkOut(residenceUuid: snap.residenceId, visitorId: visitorId);
      } else {
        await repo.checkIn(residenceUuid: snap.residenceId, visitorId: visitorId);
      }
      await _loadInitial();
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
      return false;
    }
  }

  Future<void> loadMore() async {}

  String _cacheTabKey(int tab, bool allOvertimeSection) =>
      allOvertimeSection ? VisitorTabStatus.allOvertimeCacheKey : VisitorTabStatus.cacheKeyForTab(tab);

  Future<void> _load({
    required DateTime day,
    required int tab,
    required bool search,
    required String query,
    bool? allOvertimeSection,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    final overtimeSection = allOvertimeSection ?? state.allOvertimeSection;
    final tabKey = _cacheTabKey(tab, overtimeSection);

    if (!await isDeviceOnline(ref)) {
      final snap = await DashboardPrefs.loadSnapshot();
      if (snap.residenceId.isNotEmpty) {
        final cached = await _loadVisitorsFromCache(
          residenceUuid: snap.residenceId,
          day: day,
          tab: tab,
          tabKey: tabKey,
          search: search,
          query: query,
          allOvertimeSection: overtimeSection,
        );
        if (cached != null) {
          state = cached;
          return;
        }
      }
      state = state.copyWith(
        loading: false,
        error: offlineNoCachedDataMessage(),
      );
      return;
    }

    try {
      final data = await _fetchPageData(
        day: day,
        tab: tab,
        search: search,
        query: query,
        allOvertimeSection: overtimeSection,
        tabKey: tabKey,
      );

      state = VisitorState(
        selectedDay: day,
        tabIndex: tab,
        items: data.items,
        page: 1,
        hasMore: false,
        loadingMore: false,
        allOvertimeSection: overtimeSection,
        searchActive: search && query.trim().isNotEmpty,
        searchQuery: search && query.trim().isNotEmpty ? query : '',
        totalCheckIn: data.totalCheckIn,
        totalIncoming: data.totalIncoming,
        totalOvertime: data.totalOvertime,
        totalVisitors: data.totalVisitors,
        totalCheckedOut: data.totalCheckedOut,
        loading: false,
        fromCache: false,
        cacheSavedAt: null,
      );
    } on DioException catch (e) {
      final snap = await DashboardPrefs.loadSnapshot();
      if (isNetworkError(e) && snap.residenceId.isNotEmpty) {
        final cached = await _loadVisitorsFromCache(
          residenceUuid: snap.residenceId,
          day: day,
          tab: tab,
          tabKey: tabKey,
          search: search,
          query: query,
          allOvertimeSection: overtimeSection,
        );
        if (cached != null) {
          state = cached;
          return;
        }
      }
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
    } catch (e) {
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
    }
  }

  Future<VisitorState?> _loadVisitorsFromCache({
    required String residenceUuid,
    required DateTime day,
    required int tab,
    required String tabKey,
    required bool search,
    required String query,
    required bool allOvertimeSection,
  }) async {
    final cached = await GuardListCache.readVisitors(
      residenceUuid: residenceUuid,
      day: day,
      tabKey: tabKey,
      allOvertimeSection: allOvertimeSection,
    );
    if (cached == null) return null;
    var items = cached.items;
    if (search && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      items = items
          .where(
            (e) =>
                e.name.toLowerCase().contains(q) ||
                e.unitLabel.toLowerCase().contains(q) ||
                e.carPlate.toLowerCase().contains(q) ||
                e.passId.toLowerCase().contains(q),
          )
          .toList();
    }
    return VisitorState(
      selectedDay: day,
      tabIndex: tab,
      items: items,
      page: 1,
      hasMore: false,
      loadingMore: false,
      allOvertimeSection: allOvertimeSection,
      searchActive: search && query.trim().isNotEmpty,
      searchQuery: search && query.trim().isNotEmpty ? query : '',
      totalCheckIn: cached.totalCheckIn,
      totalIncoming: cached.totalIncoming,
      totalOvertime: cached.totalOvertime,
      totalVisitors: cached.totalVisitors,
      totalCheckedOut: cached.totalCheckedOut,
      loading: false,
      fromCache: true,
      cacheSavedAt: cached.savedAt,
    );
  }

  Future<_VisitorFetchData> _fetchPageData({
    required DateTime day,
    required int tab,
    required bool search,
    required String query,
    required bool allOvertimeSection,
    required String tabKey,
  }) async {
    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) {
      return const _VisitorFetchData(items: [], hasMore: false);
    }

    final repo = ref.read(guardVisitorRepositoryProvider);
    final String? status = allOvertimeSection
        ? GuardVisitorApiStatus.overtime
        : VisitorTabStatus.apiStatusForTab(tab);

    final result = await repo.fetchVisitors(
      snap.residenceId,
      date: allOvertimeSection ? null : day,
      status: status,
    );

    var items = result.items;

    if (search && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      items = items
          .where(
            (e) =>
                e.name.toLowerCase().contains(q) ||
                e.unitLabel.toLowerCase().contains(q) ||
                e.carPlate.toLowerCase().contains(q) ||
                e.passId.toLowerCase().contains(q),
          )
          .toList();
    }

    final c = result.counts;
    await GuardListCache.saveVisitors(
      residenceUuid: snap.residenceId,
      day: day,
      tabKey: tabKey,
      allOvertimeSection: allOvertimeSection,
      responseDate: result.date,
      totalCheckIn: c.checkedIn,
      totalIncoming: c.upcoming,
      totalOvertime: c.overtime,
      totalVisitors: c.allVisitors,
      items: result.items,
      totalCheckedOut: c.checkedOut,
    );

    return _VisitorFetchData(
      items: items,
      hasMore: false,
      totalCheckIn: c.checkedIn,
      totalIncoming: c.upcoming,
      totalOvertime: c.overtime,
      totalVisitors: c.allVisitors,
      totalCheckedOut: c.checkedOut,
    );
  }
}

class _VisitorFetchData {
  const _VisitorFetchData({
    required this.items,
    required this.hasMore,
    this.totalCheckIn,
    this.totalIncoming,
    this.totalOvertime,
    this.totalVisitors,
    this.totalCheckedOut,
  });

  final List<VisitorListItem> items;
  final bool hasMore;
  final int? totalCheckIn;
  final int? totalIncoming;
  final int? totalOvertime;
  final int? totalVisitors;
  final int? totalCheckedOut;
}
