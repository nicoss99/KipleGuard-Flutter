/// Values applied to the booking list API filter (Android `ListBookingActivity` / `filterActive`).
class BookingFilterQuery {
  const BookingFilterQuery({
    this.submittedOnDay,
    this.categoryUuid,
    this.roomUuid,
  });

  final DateTime? submittedOnDay;
  final String? categoryUuid;
  final String? roomUuid;

  static const empty = BookingFilterQuery();

  bool get active =>
      submittedOnDay != null ||
      (categoryUuid != null && categoryUuid!.isNotEmpty) ||
      (roomUuid != null && roomUuid!.isNotEmpty);
}
