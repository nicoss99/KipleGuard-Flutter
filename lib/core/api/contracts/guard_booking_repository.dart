import '../../../page/booking/booking_guard_models.dart';
import '../../../page/booking/booking_parsers.dart';

/// Guard residence booking APIs.
abstract interface class GuardBookingRepository {
  Future<GuardBookingListResult> fetchBookings({
    required String residenceUuid,
    required DateTime date,
    required BookingTabApi tab,
  });

  Future<GuardBookingRow> fetchBookingDetail({
    required String residenceUuid,
    required int bookingId,
  });

  Future<GuardBookingRow> checkIn({
    required String residenceUuid,
    required int bookingId,
    required String currentTime,
  });

  Future<GuardBookingRow> checkOut({
    required String residenceUuid,
    required int bookingId,
    required String currentTime,
  });
}
