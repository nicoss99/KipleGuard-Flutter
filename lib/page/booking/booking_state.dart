import 'booking_filter_query.dart';
import 'booking_model.dart';

enum BookingTab { allBookings, checkedIn, upcoming }

extension BookingTabIndex on BookingTab {
  int get tabIndex => switch (this) {
        BookingTab.allBookings => 0,
        BookingTab.checkedIn => 1,
        BookingTab.upcoming => 2,
      };

  static BookingTab fromIndex(int index) => switch (index) {
        0 => BookingTab.allBookings,
        1 => BookingTab.checkedIn,
        _ => BookingTab.upcoming,
      };
}

class BookingListState {
  const BookingListState({
    required this.selectedDay,
    required this.tab,
    required this.items,
    required this.loading,
    this.error,
    this.totalAllBookings,
    this.totalCheckedIn,
    this.totalUpcoming,
    this.filterQuery = BookingFilterQuery.empty,
    this.searchQuery = '',
    this.fromCache = false,
    this.cacheSavedAt,
  });

  final DateTime selectedDay;
  final BookingTab tab;
  final List<BookingListItem> items;
  final bool loading;
  final String? error;
  final int? totalAllBookings;
  final int? totalCheckedIn;
  final int? totalUpcoming;
  final BookingFilterQuery filterQuery;
  final String searchQuery;
  final bool fromCache;
  final DateTime? cacheSavedAt;

  factory BookingListState.initial() => BookingListState(
        selectedDay: DateTime.now(),
        tab: BookingTab.allBookings,
        items: const [],
        loading: true,
        filterQuery: BookingFilterQuery.empty,
        searchQuery: '',
      );

  BookingListState copyWith({
    DateTime? selectedDay,
    BookingTab? tab,
    List<BookingListItem>? items,
    bool? loading,
    String? error,
    bool clearError = false,
    int? totalAllBookings,
    int? totalCheckedIn,
    int? totalUpcoming,
    BookingFilterQuery? filterQuery,
    String? searchQuery,
    bool? fromCache,
    DateTime? cacheSavedAt,
    bool clearCacheMeta = false,
  }) {
    return BookingListState(
      selectedDay: selectedDay ?? this.selectedDay,
      tab: tab ?? this.tab,
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      totalAllBookings: totalAllBookings ?? this.totalAllBookings,
      totalCheckedIn: totalCheckedIn ?? this.totalCheckedIn,
      totalUpcoming: totalUpcoming ?? this.totalUpcoming,
      filterQuery: filterQuery ?? this.filterQuery,
      searchQuery: searchQuery ?? this.searchQuery,
      fromCache: clearCacheMeta ? false : (fromCache ?? this.fromCache),
      cacheSavedAt: clearCacheMeta ? null : (cacheSavedAt ?? this.cacheSavedAt),
    );
  }
}
