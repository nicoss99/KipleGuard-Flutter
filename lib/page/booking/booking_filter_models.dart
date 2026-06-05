/// Booking filter options from `GET .../bookings/filters`.
class BookingFilterOption {
  const BookingFilterOption({required this.label, required this.value});

  final String label;
  final String value;
}

class BookingFacilityFilter {
  const BookingFacilityFilter({required this.label, required this.id});

  final String label;
  final int id;
}

class GuardBookingFilters {
  const GuardBookingFilters({
    required this.statuses,
    required this.facilities,
  });

  final List<BookingFilterOption> statuses;
  final List<BookingFacilityFilter> facilities;
}
