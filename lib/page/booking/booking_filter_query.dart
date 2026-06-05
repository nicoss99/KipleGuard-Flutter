/// Values applied to the booking list API filter.
class BookingFilterQuery {
  const BookingFilterQuery({
    this.submittedOnDay,
    this.facilityId,
    this.facilityLabel,
  });

  final DateTime? submittedOnDay;
  final int? facilityId;
  final String? facilityLabel;

  static const empty = BookingFilterQuery();

  bool get active => submittedOnDay != null || facilityId != null;
}
