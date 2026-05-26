import 'package:intl/intl.dart';

import 'booking_filter_query.dart';
import 'booking_model.dart';

List<BookingListItem> applyBookingListFilters({
  required List<BookingListItem> items,
  required BookingFilterQuery filter,
  required String searchQuery,
}) {
  var out = items;
  final submitted = filter.submittedOnDay;
  if (submitted != null) {
    final d = DateFormat('yyyy-MM-dd').format(submitted);
    out = out.where((e) => e.submittedDate == d).toList();
  }
  final category = filter.categoryName;
  if (category != null && category.isNotEmpty) {
    out = out
        .where((e) => e.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
  final room = filter.roomName;
  if (room != null && room.isNotEmpty) {
    out = out
        .where((e) => e.bookingName.toLowerCase() == room.toLowerCase())
        .toList();
  }
  final t = searchQuery.trim();
  if (t.length >= 3) {
    final q = t.toLowerCase();
    out = out
        .where(
          (e) =>
              e.name.toLowerCase().contains(q) ||
              e.unitLabel.toLowerCase().contains(q) ||
              e.bookingNumber.toLowerCase().contains(q) ||
              e.mobileNumber.toLowerCase().contains(q),
        )
        .toList();
  }
  return out;
}
