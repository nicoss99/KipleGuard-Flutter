import 'booking_guard_models.dart';

/// One row in the booking list.
class BookingListItem {
  const BookingListItem({
    required this.id,
    required this.bookingNumber,
    required this.name,
    required this.mobileNumber,
    required this.unitLabel,
    required this.category,
    required this.bookingName,
    required this.guardStatus,
    required this.timeRangeLabel,
    required this.durationLabel,
    required this.submittedDate,
    this.samenityId,
  });

  final int id;
  final String bookingNumber;
  final String name;
  final String mobileNumber;
  final String unitLabel;
  final String category;
  final String bookingName;
  final String guardStatus;
  final String timeRangeLabel;
  final String durationLabel;
  final String submittedDate;
  final int? samenityId;

  factory BookingListItem.fromGuard(GuardBookingRow row) => BookingListItem(
        id: row.id,
        bookingNumber: row.bookingNumber,
        name: row.name,
        mobileNumber: row.mobileNumber,
        unitLabel: row.unitLabel,
        category: row.category,
        bookingName: row.bookingName,
        guardStatus: row.guardStatus,
        timeRangeLabel: row.timeRangeLabel,
        durationLabel: row.durationLabel,
        submittedDate: row.submittedDate,
        samenityId: row.samenityId,
      );
}
