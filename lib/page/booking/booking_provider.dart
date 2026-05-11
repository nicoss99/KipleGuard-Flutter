import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api_error_message.dart';
import '../../core/app_logger.dart';
import '../../core/dashboard_prefs.dart';
import 'booking_filter_query.dart';
import 'booking_model.dart';
import 'booking_repository.dart';
import 'booking_state.dart';
import 'booking_strings.dart';

final bookingListProvider =
    NotifierProvider<BookingListNotifier, BookingListState>(
      BookingListNotifier.new,
    );

class BookingListNotifier extends Notifier<BookingListState> {
  @override
  BookingListState build() => BookingListState.initial();

  Future<void> setDay(DateTime day) async {
    final d = DateTime(day.year, day.month, day.day);
    state = state.copyWith(
      selectedDay: d,
      items: const [],
      offset: 0,
      hasMore: false,
      clearError: true,
    );
    await refresh();
  }

  Future<void> applyFilters(BookingFilterQuery query) async {
    state = state.copyWith(
      filterQuery: query,
      searchQuery: '',
      items: const [],
      offset: 0,
      hasMore: false,
      clearError: true,
    );
    await refresh();
  }

  Future<void> clearListFilters() async {
    state = state.copyWith(
      filterQuery: BookingFilterQuery.empty,
      searchQuery: '',
      items: const [],
      offset: 0,
      hasMore: false,
      clearError: true,
    );
    await refresh();
  }

  Future<void> setSearchQuery(String query) async {
    final t = query.trim();
    state = state.copyWith(
      searchQuery: t,
      filterQuery: t.length >= 3 ? BookingFilterQuery.empty : state.filterQuery,
      items: const [],
      offset: 0,
      hasMore: false,
      clearError: true,
    );
    await refresh();
  }

  Future<void> setTab(BookingTab tab) async {
    if (state.tab == tab) return;
    state = state.copyWith(
      tab: tab,
      items: const [],
      offset: 0,
      hasMore: false,
      clearError: true,
    );
    await refresh();
  }

  Future<void> refresh() async {
    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) {
      state = state.copyWith(loading: false, error: 'No residence selected');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final filter = state.tab == BookingTab.checkedIn
          ? repo.listFilterCheckedIn(
              residenceUuid: snap.residenceId,
              dayLocal: state.selectedDay,
              query: state.filterQuery,
              searchQuery: state.searchQuery,
            )
          : repo.listFilterUpcoming(
              residenceUuid: snap.residenceId,
              dayLocal: state.selectedDay,
              query: state.filterQuery,
              searchQuery: state.searchQuery,
            );
      final page = await repo.fetchBookingsPage(filter: filter, offset: 0);
      final items = page.resources
          .map(
            (m) => BookingListItem.fromResource(
              m,
              isUpcomingTab: state.tab == BookingTab.upcoming,
            ),
          )
          .where((e) => e.uuid.isNotEmpty)
          .toList();
      state = state.copyWith(
        items: items,
        offset: items.length,
        loading: false,
        hasMore: page.resources.length >= 10,
        totalCheckedIn: state.tab == BookingTab.checkedIn
            ? page.count
            : state.totalCheckedIn,
        totalUpcoming: state.tab == BookingTab.upcoming
            ? page.count
            : state.totalUpcoming,
      );
    } catch (e, st) {
      AppLog.error('Booking list', tag: 'Booking', error: e, stackTrace: st);
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.hasMore) return;
    if (state.items.isEmpty) return;
    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) return;
    state = state.copyWith(loadingMore: true, clearError: true);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final filter = state.tab == BookingTab.checkedIn
          ? repo.listFilterCheckedIn(
              residenceUuid: snap.residenceId,
              dayLocal: state.selectedDay,
              query: state.filterQuery,
              searchQuery: state.searchQuery,
            )
          : repo.listFilterUpcoming(
              residenceUuid: snap.residenceId,
              dayLocal: state.selectedDay,
              query: state.filterQuery,
              searchQuery: state.searchQuery,
            );
      final page = await repo.fetchBookingsPage(
        filter: filter,
        offset: state.offset,
      );
      final more = page.resources
          .map(
            (m) => BookingListItem.fromResource(
              m,
              isUpcomingTab: state.tab == BookingTab.upcoming,
            ),
          )
          .where((e) => e.uuid.isNotEmpty)
          .toList();
      state = state.copyWith(
        items: [...state.items, ...more],
        offset: state.offset + more.length,
        loadingMore: false,
        hasMore: more.length >= 10,
      );
    } catch (e, st) {
      AppLog.error(
        'Booking load more',
        tag: 'Booking',
        error: e,
        stackTrace: st,
      );
      state = state.copyWith(
        loadingMore: false,
        error: BookingStrings.loadFailed,
      );
    }
  }
}
