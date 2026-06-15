import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api_error_message.dart';
import '../../core/offline/offline_messages.dart';
import '../../core/app_logger.dart';
import '../../core/cache/guard_list_cache.dart';
import '../../core/connectivity/connectivity_refresh.dart';
import '../../core/dashboard_prefs.dart';
import '../../core/network/dio_network.dart';
import 'booking_filter_query.dart';
import 'booking_guard_models.dart';
import 'booking_list_filters.dart';
import 'booking_model.dart';
import 'booking_parsers.dart';
import 'booking_repository.dart';
import 'booking_search_helpers.dart';
import 'booking_state.dart';

final bookingListProvider =
    NotifierProvider<BookingListNotifier, BookingListState>(
      BookingListNotifier.new,
    );

class BookingListNotifier extends Notifier<BookingListState> {
  @override
  BookingListState build() {
    Future<void>.microtask(refresh);
    return BookingListState.initial();
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<void> previousDay() =>
      setDay(state.selectedDay.subtract(const Duration(days: 1)));

  Future<void> nextDay() => setDay(state.selectedDay.add(const Duration(days: 1)));

  Future<void> jumpToToday() async {
    final t = DateTime.now();
    final d = DateTime(t.year, t.month, t.day);
    state = state.copyWith(
      selectedDay: d,
      filterQuery: BookingFilterQuery.empty,
      items: const [],
      searchQuery: '',
      clearSearchPool: true,
      clearError: true,
    );
    await refresh();
  }

  Future<void> setDay(DateTime day) async {
    final d = DateTime(day.year, day.month, day.day);
    state = state.copyWith(
      selectedDay: d,
      filterQuery: _filterForDayChange(state.filterQuery, d),
      items: const [],
      searchQuery: '',
      clearSearchPool: true,
      clearError: true,
    );
    await refresh();
  }

  /// Drop submitted-on filter when the calendar day no longer matches.
  BookingFilterQuery _filterForDayChange(BookingFilterQuery filter, DateTime day) {
    final submitted = filter.submittedOnDay;
    if (submitted == null || _isSameDay(submitted, day)) return filter;
    return BookingFilterQuery(
      facilityId: filter.facilityId,
      facilityLabel: filter.facilityLabel,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> applyFilters(BookingFilterQuery query) async {
    final submitted = query.submittedOnDay;
    state = state.copyWith(
      filterQuery: query,
      selectedDay: submitted != null
          ? DateTime(submitted.year, submitted.month, submitted.day)
          : state.selectedDay,
      searchQuery: '',
      clearSearchPool: true,
      clearError: true,
    );
    await refresh();
  }

  Future<void> clearListFilters() async {
    state = state.copyWith(
      filterQuery: BookingFilterQuery.empty,
      searchQuery: '',
      clearSearchPool: true,
      clearError: true,
    );
    await refresh();
  }

  Future<void> setSearchQuery(String query) async {
    final t = query.trim();
    state = state.copyWith(
      searchQuery: t,
      filterQuery: t.length >= 3 ? BookingFilterQuery.empty : state.filterQuery,
      clearSearchPool: t.length < 3,
      clearError: true,
    );
    await refresh();
  }

  Future<void> clearSearch() async {
    if (state.searchQuery.isEmpty) return;
    state = state.copyWith(
      searchQuery: '',
      clearSearchPool: true,
      clearError: true,
    );
    await refresh();
  }

  Future<void> setTab(BookingTab tab) async {
    if (state.tab == tab) return;
    if (bookingUsesClientTabPool(
          filter: state.filterQuery,
          searchQuery: state.searchQuery,
        ) &&
        state.searchResultPool.isNotEmpty) {
      state = state.copyWith(
        tab: tab,
        items: applyBookingTabFilter(state.searchResultPool, tab),
        clearError: true,
      );
      return;
    }
    state = state.copyWith(tab: tab, items: const [], clearError: true);
    await refresh();
  }

  BookingTabApi _tabApi(BookingTab tab) {
    if (bookingUsesClientTabPool(
      filter: state.filterQuery,
      searchQuery: state.searchQuery,
    )) {
      return BookingTabApi.allBookings;
    }
    return switch (tab) {
      BookingTab.allBookings => BookingTabApi.allBookings,
      BookingTab.checkedIn => BookingTabApi.checkedIn,
      BookingTab.upcoming => BookingTabApi.upcoming,
    };
  }

  List<BookingListItem> _filteredPool(List<BookingListItem> source) =>
      applyBookingListFilters(
        items: source,
        filter: state.filterQuery,
        searchQuery: state.searchQuery,
      );

  List<BookingListItem> _displayItems(List<BookingListItem> source) {
    final poolMode = bookingUsesClientTabPool(
      filter: state.filterQuery,
      searchQuery: state.searchQuery,
    );
    if (poolMode) {
      return applyBookingTabFilter(_filteredPool(source), state.tab);
    }
    return buildBookingDisplayItems(
      source: source,
      filter: state.filterQuery,
      searchQuery: state.searchQuery,
      tab: state.tab,
    );
  }

  void _finishWithMapped({
    required List<BookingListItem> mapped,
    required GuardBookingListResult result,
    required bool fromCache,
    DateTime? cacheSavedAt,
  }) {
    final poolMode = bookingUsesClientTabPool(
      filter: state.filterQuery,
      searchQuery: state.searchQuery,
    );
    final pool = poolMode ? _filteredPool(mapped) : const <BookingListItem>[];
    final counts = poolMode
        ? computeBookingCounts(pool)
        : (
            all: result.counts.allBookings,
            checkedIn: result.counts.checkedIn,
            upcoming: result.counts.upcoming,
          );

    state = state.copyWith(
      items: poolMode ? applyBookingTabFilter(pool, state.tab) : _displayItems(mapped),
      searchResultPool: poolMode ? pool : const [],
      loading: false,
      totalAllBookings: counts.all,
      totalCheckedIn: counts.checkedIn,
      totalUpcoming: counts.upcoming,
      fromCache: fromCache,
      cacheSavedAt: cacheSavedAt,
      clearCacheMeta: !fromCache,
      clearSearchPool: !poolMode,
    );
  }

  Future<void> refresh() async {
    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) {
      state = state.copyWith(loading: false, error: 'No residence selected');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);

    final apiTab = _tabApi(state.tab);
    final hasSearch = bookingSearchActive(state.searchQuery);
    final hasFilter = state.filterQuery.active;

    if (!await isDeviceOnline(ref)) {
      final cached = await GuardListCache.readBookings(
        residenceUuid: snap.residenceId,
        day: state.selectedDay,
        tab: bookingTabApiValue(apiTab),
      );
      if (cached != null) {
        final mapped = cached.result.bookings.map(BookingListItem.fromGuard).toList();
        _finishWithMapped(
          mapped: mapped,
          result: cached.result,
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
      final repo = ref.read(bookingRepositoryProvider);
      final result = await repo.fetchBookings(
        residenceUuid: snap.residenceId,
        date: state.selectedDay,
        tab: apiTab,
        samenityId: state.filterQuery.facilityId,
        search: state.searchQuery,
      );
      final mapped = result.bookings.map(BookingListItem.fromGuard).toList();
      if (!hasSearch && !hasFilter) {
        await GuardListCache.saveBookings(
          residenceUuid: snap.residenceId,
          day: state.selectedDay,
          tab: bookingTabApiValue(apiTab),
          result: result,
        );
      }
      _finishWithMapped(mapped: mapped, result: result, fromCache: false);
    } on DioException catch (e, st) {
      AppLog.error('Booking list', tag: 'Booking', error: e, stackTrace: st);
      if (isNetworkError(e)) {
        final cached = await GuardListCache.readBookings(
          residenceUuid: snap.residenceId,
          day: state.selectedDay,
          tab: bookingTabApiValue(apiTab),
        );
        if (cached != null) {
          final mapped =
              cached.result.bookings.map(BookingListItem.fromGuard).toList();
          _finishWithMapped(
            mapped: mapped,
            result: cached.result,
            fromCache: true,
            cacheSavedAt: cached.savedAt,
          );
          return;
        }
      }
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
    } catch (e, st) {
      AppLog.error('Booking list', tag: 'Booking', error: e, stackTrace: st);
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
    }
  }
}
