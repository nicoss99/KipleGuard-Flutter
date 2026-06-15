import 'booking_filter_query.dart';
import 'booking_list_filters.dart';
import 'booking_model.dart';
import 'booking_state.dart';

/// Tab filter applied client-side while search or list filters are active.
List<BookingListItem> applyBookingTabFilter(
  List<BookingListItem> items,
  BookingTab tab,
) =>
    switch (tab) {
      BookingTab.checkedIn => items
          .where((e) => _normalizeGuardStatus(e.guardStatus) == 'checked_in')
          .toList(),
      BookingTab.upcoming => items
          .where((e) => _normalizeGuardStatus(e.guardStatus) == 'upcoming')
          .toList(),
      BookingTab.allBookings => items,
    };

String _normalizeGuardStatus(String raw) =>
    raw.trim().toLowerCase().replaceAll('-', '_');

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
  if (tab == BookingTab.allBookings) return filtered;
  return applyBookingTabFilter(filtered, tab);
}

/// Summary card counts from a filtered booking pool (search / list filters).
({int all, int checkedIn, int upcoming}) computeBookingCounts(
  List<BookingListItem> items,
) {
  var checkedIn = 0;
  var upcoming = 0;
  for (final e in items) {
    switch (_normalizeGuardStatus(e.guardStatus)) {
      case 'checked_in':
        checkedIn++;
      case 'upcoming':
        upcoming++;
      default:
        break;
    }
  }
  return (all: items.length, checkedIn: checkedIn, upcoming: upcoming);
}

bool bookingUsesClientTabPool({
  required BookingFilterQuery filter,
  required String searchQuery,
}) =>
    filter.active || bookingSearchActive(searchQuery);
