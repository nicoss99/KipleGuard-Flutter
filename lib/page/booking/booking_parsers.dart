import '../../core/guard_api_message.dart';
import 'booking_guard_models.dart';

String bookingTabApiValue(BookingTabApi tab) => switch (tab) {
      BookingTabApi.allBookings => 'all_bookings',
      BookingTabApi.checkedIn => 'checked_in',
      BookingTabApi.upcoming => 'upcoming',
    };

enum BookingTabApi { allBookings, checkedIn, upcoming }

GuardBookingListResult parseBookingListFromApi(Map<String, dynamic>? body) {
  final data = guardApiData(body);
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
  final data = guardApiData(body);
  final raw = data?['booking'];
  if (raw is! Map<String, dynamic>) {
    throw StateError('Invalid booking payload');
  }
  return GuardBookingRow.fromJson(raw);
}
