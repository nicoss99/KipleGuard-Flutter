import '../../core/guard_api_message.dart';
import 'booking_filter_models.dart';
import 'booking_guard_models.dart';

String bookingTabApiValue(BookingTabApi tab) => switch (tab) {
      BookingTabApi.allBookings => 'all_bookings',
      BookingTabApi.checkedIn => 'checked_in',
      BookingTabApi.upcoming => 'upcoming',
    };

enum BookingTabApi { allBookings, checkedIn, upcoming }

/// [GuardHttpClient] already unwraps `data`; accept full body for cache/tests.
Map<String, dynamic>? bookingApiPayload(Map<String, dynamic>? body) =>
    guardApiData(body) ?? body;

GuardBookingListResult parseBookingListFromApi(Map<String, dynamic>? body) {
  final data = bookingApiPayload(body);
  final raw = data?['bookings'];
  final list = raw is List
      ? raw
          .whereType<Map<String, dynamic>>()
          .map(GuardBookingRow.fromJson)
          .where((b) => b.id > 0)
          .toList()
      : <GuardBookingRow>[];
  return GuardBookingListResult(
    date: data?['date']?.toString() ?? '',
    tab: data?['tab']?.toString() ?? '',
    counts: GuardBookingCounts.fromJson(
      data?['counts'] as Map<String, dynamic>?,
    ),
    bookings: list,
  );
}

GuardBookingRow parseBookingDetailFromApi(Map<String, dynamic>? body) {
  final data = bookingApiPayload(body);
  final raw = data?['booking'];
  if (raw is! Map<String, dynamic>) {
    throw StateError('Invalid booking payload');
  }
  return GuardBookingRow.fromJson(raw);
}

GuardBookingFilters parseBookingFiltersFromApi(Map<String, dynamic>? body) {
  final data = bookingApiPayload(body);
  final statusesRaw = data?['statuses'];
  final facilitiesRaw = data?['facilities'];
  return GuardBookingFilters(
    statuses: _parseFilterOptions(statusesRaw),
    facilities: _parseFacilityFilters(facilitiesRaw),
  );
}

List<BookingFilterOption> _parseFilterOptions(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map(
        (e) => BookingFilterOption(
          label: e['label']?.toString() ?? '',
          value: e['value']?.toString() ?? '',
        ),
      )
      .where((e) => e.label.isNotEmpty && e.value.isNotEmpty)
      .toList();
}

List<BookingFacilityFilter> _parseFacilityFilters(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) {
        final id = _jsonInt(e['samenity_id'] ?? e['value']);
        final label = e['label']?.toString() ?? '';
        if (id <= 0 || label.isEmpty) return null;
        return BookingFacilityFilter(label: label, id: id);
      })
      .whereType<BookingFacilityFilter>()
      .toList();
}

int _jsonInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
