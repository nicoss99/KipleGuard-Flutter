import 'booking_filter_query.dart';
import 'booking_model.dart';

enum BookingTab { checkedIn, upcoming }

class BookingListState {
  const BookingListState({
    required this.selectedDay,
    required this.tab,
    required this.items,
    required this.loading,
    this.error,
    this.totalCheckedIn,
    this.totalUpcoming,
    this.filterQuery = BookingFilterQuery.empty,
    this.searchQuery = '',
  });

  final DateTime selectedDay;
  final BookingTab tab;
  final List<BookingListItem> items;
  final bool loading;
  final String? error;
  final int? totalCheckedIn;
  final int? totalUpcoming;
  final BookingFilterQuery filterQuery;
  final String searchQuery;

  factory BookingListState.initial() => BookingListState(
        selectedDay: DateTime.now(),
        tab: BookingTab.checkedIn,
        items: const [],
        loading: false,
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
    int? totalCheckedIn,
    int? totalUpcoming,
    BookingFilterQuery? filterQuery,
    String? searchQuery,
  }) {
    return BookingListState(
      selectedDay: selectedDay ?? this.selectedDay,
      tab: tab ?? this.tab,
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      totalCheckedIn: totalCheckedIn ?? this.totalCheckedIn,
      totalUpcoming: totalUpcoming ?? this.totalUpcoming,
      filterQuery: filterQuery ?? this.filterQuery,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
