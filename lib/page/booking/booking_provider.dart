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
import 'booking_list_filters.dart';
import 'booking_model.dart';
import 'booking_parsers.dart';
import 'booking_repository.dart';
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

  Future<void> setDay(DateTime day) async {
    final d = DateTime(day.year, day.month, day.day);
    state = state.copyWith(
      selectedDay: d,
      items: const [],
      clearError: true,
    );
    await refresh();
  }

  Future<void> applyFilters(BookingFilterQuery query) async {
    state = state.copyWith(
      filterQuery: query,
      searchQuery: '',
      clearError: true,
    );
    await refresh();
  }

  Future<void> clearListFilters() async {
    state = state.copyWith(
      filterQuery: BookingFilterQuery.empty,
      searchQuery: '',
      clearError: true,
    );
    await refresh();
  }

  Future<void> setSearchQuery(String query) async {
    final t = query.trim();
    state = state.copyWith(
      searchQuery: t,
      filterQuery: t.length >= 3 ? BookingFilterQuery.empty : state.filterQuery,
      clearError: true,
    );
    await refresh();
  }

  Future<void> setTab(BookingTab tab) async {
    if (state.tab == tab) return;
    state = state.copyWith(tab: tab, items: const [], clearError: true);
    await refresh();
  }

  BookingTabApi _tabApi(BookingTab tab) => switch (tab) {
        BookingTab.allBookings => BookingTabApi.allBookings,
        BookingTab.checkedIn => BookingTabApi.checkedIn,
        BookingTab.upcoming => BookingTabApi.upcoming,
      };

  Future<void> refresh() async {
    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) {
      state = state.copyWith(loading: false, error: 'No residence selected');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);

    if (!await isDeviceOnline(ref)) {
      final cached = await GuardListCache.readBookings(
        residenceUuid: snap.residenceId,
        day: state.selectedDay,
        tab: bookingTabApiValue(_tabApi(state.tab)),
      );
      if (cached != null) {
        final mapped = cached.result.bookings.map(BookingListItem.fromGuard).toList();
        final items = applyBookingListFilters(
          items: mapped,
          filter: state.filterQuery,
          searchQuery: state.searchQuery,
        );
        state = state.copyWith(
          items: items,
          loading: false,
          totalAllBookings: cached.result.counts.allBookings,
          totalCheckedIn: cached.result.counts.checkedIn,
          totalUpcoming: cached.result.counts.upcoming,
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
        tab: _tabApi(state.tab),
      );
      final mapped = result.bookings.map(BookingListItem.fromGuard).toList();
      final items = applyBookingListFilters(
        items: mapped,
        filter: state.filterQuery,
        searchQuery: state.searchQuery,
      );
      await GuardListCache.saveBookings(
        residenceUuid: snap.residenceId,
        day: state.selectedDay,
        tab: bookingTabApiValue(_tabApi(state.tab)),
        result: result,
      );
      state = state.copyWith(
        items: items,
        loading: false,
        totalAllBookings: result.counts.allBookings,
        totalCheckedIn: result.counts.checkedIn,
        totalUpcoming: result.counts.upcoming,
        clearCacheMeta: true,
      );
    } on DioException catch (e, st) {
      AppLog.error('Booking list', tag: 'Booking', error: e, stackTrace: st);
      if (isNetworkError(e)) {
        final cached = await GuardListCache.readBookings(
          residenceUuid: snap.residenceId,
          day: state.selectedDay,
          tab: bookingTabApiValue(_tabApi(state.tab)),
        );
        if (cached != null) {
          final mapped =
              cached.result.bookings.map(BookingListItem.fromGuard).toList();
          final items = applyBookingListFilters(
            items: mapped,
            filter: state.filterQuery,
            searchQuery: state.searchQuery,
          );
          state = state.copyWith(
            items: items,
            loading: false,
            totalAllBookings: cached.result.counts.allBookings,
            totalCheckedIn: cached.result.counts.checkedIn,
            totalUpcoming: cached.result.counts.upcoming,
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
