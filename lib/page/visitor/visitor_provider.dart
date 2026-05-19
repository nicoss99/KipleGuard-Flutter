import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api_error_message.dart';
import '../../core/auth_prefs.dart';
import '../../core/dashboard_prefs.dart';
import 'visitor_model.dart';
import 'visitor_query_builder.dart';
import 'visitor_repository.dart';
import 'visitor_residence_filter.dart';
import 'visitor_state.dart';

final visitorProvider = NotifierProvider<VisitorNotifier, VisitorState>(VisitorNotifier.new);

class VisitorNotifier extends Notifier<VisitorState> {
  static const _defaultPageSize = 5;
  static const _allOvertimePageSize = 10;

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

  Future<void> quickAction(VisitorListItem item) async {
    if (item.qrCode.trim().isEmpty || item.residenceUuid.trim().isEmpty) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      /// Android `VisitorAdapter`: `userProfileID` = `data.created_by`; fallback to session profile.
      var profileUuid = item.createdByUuid.trim();
      if (profileUuid.isEmpty) {
        profileUuid = await AuthPrefs.readProfileUuid() ?? '';
      }
      if (profileUuid.isEmpty) {
        state = state.copyWith(loading: false, error: 'Missing profile');
        return;
      }
      await ref.read(visitorRepositoryProvider).qrVisitorScan(
        qrCodeRaw: item.qrCode,
        residenceUuid: item.residenceUuid,
        userProfileUuid: profileUuid,
      );
      await _loadInitial();
    } catch (e) {
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
    }
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    state = state.copyWith(loadingMore: true, clearError: true);
    try {
      final nextPage = state.page + 1;
      final extra = await _fetchPageData(
        day: state.selectedDay,
        tab: state.tabIndex,
        search: state.searchActive,
        query: state.searchQuery,
        allOvertimeSection: state.allOvertimeSection,
        page: nextPage,
        includeTotals: false,
      );

      final mergedItems = _mergeUnique([...state.items, ...extra.items]);
      state = state.copyWith(
        items: mergedItems,
        page: nextPage,
        hasMore: extra.hasMore,
        loadingMore: false,
        totalCheckIn: extra.totalCheckIn ?? state.totalCheckIn,
        totalIncoming: extra.totalIncoming ?? state.totalIncoming,
        totalOvertime: extra.totalOvertime ?? state.totalOvertime,
        totalVisitors: extra.totalVisitors ?? state.totalVisitors,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, error: apiErrorMessage(e));
    }
  }

  Future<void> _load({
    required DateTime day,
    required int tab,
    required bool search,
    required String query,
    bool? allOvertimeSection,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    final overtimeSection = allOvertimeSection ?? state.allOvertimeSection;
    try {
      final data = await _fetchPageData(
        day: day,
        tab: tab,
        search: search,
        query: query,
        allOvertimeSection: overtimeSection,
        page: 1,
        includeTotals: true,
      );
      state = VisitorState(
        selectedDay: day,
        tabIndex: tab,
        items: data.items,
        page: 1,
        hasMore: data.hasMore,
        loadingMore: false,
        allOvertimeSection: overtimeSection,
        searchActive: search && query.trim().isNotEmpty,
        searchQuery: search && query.trim().isNotEmpty ? query : '',
        totalCheckIn: data.totalCheckIn,
        totalIncoming: data.totalIncoming,
        totalOvertime: data.totalOvertime,
        totalVisitors: data.totalVisitors,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
    }
  }

  Future<_VisitorFetchData> _fetchPageData({
    required DateTime day,
    required int tab,
    required bool search,
    required String query,
    required bool allOvertimeSection,
    required int page,
    required bool includeTotals,
  }) async {
    final snap = await DashboardPrefs.loadSnapshot();
    final repo = ref.read(visitorRepositoryProvider);
    final clause = buildVisitorResidenceFilterClause(snap);
    if (clause.isEmpty || snap.residenceId.isEmpty) {
      return const _VisitorFetchData(items: [], hasMore: false);
    }

    final bounds = dayBoundsUtc(day);
    final offset = page;

    if (allOvertimeSection) {
      final result = await repo.fetchAllOvertimeVisitors(
        residenceClause: clause,
        offset: offset,
        limit: _allOvertimePageSize,
      );
      final hasMore = _hasMorePage(result, page, _allOvertimePageSize);
      return _VisitorFetchData(
        items: result.items,
        hasMore: hasMore,
        totalOvertime: result.total,
      );
    }

    final checkinFuture = repo.fetchRevisedVisitors(
      filter: visitorCheckInFilter(
        residenceClause: clause,
        dateStartUtc: bounds.start,
        dateEndUtc: bounds.end,
      ),
      category: VisitorListCategory.checkedIn,
      offset: offset,
      limit: _defaultPageSize,
    );
    final overtimeFuture = repo.fetchRevisedVisitors(
      filter: visitorOvertimeFilter(residenceClause: clause),
      category: VisitorListCategory.overtime,
      offset: offset,
      limit: _defaultPageSize,
    );
    final upcomingFuture = repo.fetchUpcoming(
      snap.residenceId,
      offset: offset,
      limit: _defaultPageSize,
    );

    if (search && query.trim().isNotEmpty) {
      final searchResult = await repo.searchVisitors(
        residenceUuid: snap.residenceId,
        searchText: query.trim(),
        dateVisitUtc: bounds.start,
        offset: offset,
        limit: _defaultPageSize,
      );
      final hasMore = _hasMorePage(searchResult, page, _defaultPageSize);
      if (!includeTotals) {
        return _VisitorFetchData(items: searchResult.items, hasMore: hasMore);
      }
      final totals = await Future.wait([checkinFuture, upcomingFuture, overtimeFuture]);
      return _VisitorFetchData(
        items: searchResult.items,
        hasMore: hasMore,
        totalCheckIn: totals[0].total,
        totalIncoming: totals[1].total,
        totalOvertime: totals[2].total,
        totalVisitors:
            (totals[0].total ?? 0) + (totals[1].total ?? 0) + (totals[2].total ?? 0),
      );
    }

    if (!includeTotals) {
      if (tab == 0) {
        final checkin = await checkinFuture;
        return _VisitorFetchData(
          items: checkin.items,
          hasMore: _hasMorePage(checkin, page, _defaultPageSize),
        );
      }
      if (tab == 1) {
        final upcoming = await upcomingFuture;
        return _VisitorFetchData(
          items: upcoming.items,
          hasMore: _hasMorePage(upcoming, page, _defaultPageSize),
        );
      }
      if (tab == 2) {
        final overtime = await overtimeFuture;
        return _VisitorFetchData(
          items: overtime.items,
          hasMore: _hasMorePage(overtime, page, _defaultPageSize),
        );
      }
      final results = await Future.wait([checkinFuture, upcomingFuture, overtimeFuture]);
      final checkin = results[0];
      final upcoming = results[1];
      final overtime = results[2];
      final hasMore =
          _hasMorePage(checkin, page, _defaultPageSize) ||
          _hasMorePage(upcoming, page, _defaultPageSize) ||
          _hasMorePage(overtime, page, _defaultPageSize);
      return _VisitorFetchData(
        items: _mergeUnique([...checkin.items, ...upcoming.items, ...overtime.items]),
        hasMore: hasMore,
      );
    }

    final totals = await Future.wait([checkinFuture, upcomingFuture, overtimeFuture]);
    final checkin = totals[0];
    final upcoming = totals[1];
    final overtime = totals[2];

    List<VisitorListItem> items;
    if (tab == 1) {
      items = upcoming.items;
    } else if (tab == 2) {
      items = overtime.items;
    } else if (tab == 3) {
      items = _mergeUnique([...checkin.items, ...upcoming.items, ...overtime.items]);
    } else {
      items = checkin.items;
    }

    final hasMore = switch (tab) {
      0 => _hasMorePage(checkin, page, _defaultPageSize),
      1 => _hasMorePage(upcoming, page, _defaultPageSize),
      2 => _hasMorePage(overtime, page, _defaultPageSize),
      _ =>
        _hasMorePage(checkin, page, _defaultPageSize) ||
            _hasMorePage(upcoming, page, _defaultPageSize) ||
            _hasMorePage(overtime, page, _defaultPageSize),
    };
    return _VisitorFetchData(
      items: items,
      hasMore: hasMore,
      totalCheckIn: checkin.total,
      totalIncoming: upcoming.total,
      totalOvertime: overtime.total,
      totalVisitors:
          (checkin.total ?? 0) + (upcoming.total ?? 0) + (overtime.total ?? 0),
    );
  }

  List<VisitorListItem> _mergeUnique(List<VisitorListItem> src) {
    final byId = <String, VisitorListItem>{};
    for (final e in src) {
      byId[e.uuid] = e;
    }
    return byId.values.toList();
  }

  bool _hasMorePage(VisitorListPageResult result, int page, int pageSize) {
    final pages = result.pages;
    if (pages != null && pages > 0) {
      return page < pages;
    }
    return result.items.length >= pageSize;
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
  });

  final List<VisitorListItem> items;
  final bool hasMore;
  final int? totalCheckIn;
  final int? totalIncoming;
  final int? totalOvertime;
  final int? totalVisitors;
}
