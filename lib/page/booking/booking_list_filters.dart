import 'package:intl/intl.dart';

import 'booking_filter_query.dart';
import 'booking_model.dart';

List<BookingListItem> applyBookingListFilters({
  required List<BookingListItem> items,
  required BookingFilterQuery filter,
  String searchQuery = '',
}) {
  var out = items;
  final submitted = filter.submittedOnDay;
  if (submitted != null) {
    final d = DateFormat('yyyy-MM-dd').format(submitted);
    out = out.where((e) => e.submittedDate == d).toList();
  }
  final facilityId = filter.facilityId;
  if (facilityId != null) {
    out = out.where((e) => _matchesFacility(e, facilityId, filter.facilityLabel)).toList();
  }
  final t = searchQuery.trim();
  if (t.length >= 3) {
    final q = _normalizeSearchToken(t);
    out = out.where((e) => _bookingMatchesSearch(e, q)).toList();
  }
  return out;
}

bool bookingSearchActive(String searchQuery) => searchQuery.trim().length >= 3;

bool _matchesFacility(BookingListItem item, int facilityId, String? facilityLabel) {
  final rowId = item.samenityId;
  if (rowId != null && rowId > 0) return rowId == facilityId;
  final label = facilityLabel?.trim().toLowerCase();
  if (label == null || label.isEmpty) return true;
  final category = item.category.trim().toLowerCase();
  final bookingName = item.bookingName.trim().toLowerCase();
  return category == label ||
      bookingName == label ||
      bookingName.startsWith('$label ');
}

bool _bookingMatchesSearch(BookingListItem e, String q) {
  return _containsNormalized(e.name, q) ||
      _containsNormalized(e.unitLabel, q) ||
      _containsNormalized(e.bookingNumber, q) ||
      _containsNormalized(e.mobileNumber, q) ||
      _containsNormalized(e.bookingName, q) ||
      _containsNormalized(e.category, q) ||
      _containsNormalized(e.timeRangeLabel, q);
}

bool _containsNormalized(String value, String query) =>
    _normalizeSearchToken(value).contains(query);

String _normalizeSearchToken(String raw) =>
    raw.toLowerCase().replaceAll(RegExp(r'[\s\-+()]'), '');
