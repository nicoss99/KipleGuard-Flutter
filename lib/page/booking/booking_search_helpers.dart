import 'booking_filter_query.dart';
import 'booking_list_filters.dart';
import 'booking_model.dart';
import 'booking_state.dart';

/// Tab filter applied client-side while search is active (API uses all bookings).
List<BookingListItem> applyBookingTabFilter(
  List<BookingListItem> items,
  BookingTab tab,
) =>
    switch (tab) {
      BookingTab.checkedIn =>
        items.where((e) => e.guardStatus == 'checked_in').toList(),
      BookingTab.upcoming =>
        items.where((e) => e.guardStatus == 'upcoming').toList(),
      BookingTab.allBookings => items,
    };

List<BookingListItem> buildBookingDisplayItems({
  required List<BookingListItem> source,
  required BookingFilterQuery filter,
  required String searchQuery,
  required BookingTab tab,
}) {
  final filtered = applyBookingListFilters(
    items: source,
    filter: filter,
    searchQuery: searchQuery,
  );
  if (!bookingSearchActive(searchQuery)) return filtered;
  return applyBookingTabFilter(filtered, tab);
}
