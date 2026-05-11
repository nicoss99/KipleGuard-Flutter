/// One row in the booking list (`ListBookingObject` / adapter).
class BookingListItem {
  const BookingListItem({
    required this.uuid,
    required this.roomName,
    required this.category,
    required this.startTimeRaw,
    required this.endTimeRaw,
    required this.bookingName,
    required this.bookingUnit,
    required this.isUpcomingTab,
    this.lastScan,
  });

  final String uuid;
  final String roomName;
  final String category;
  final String startTimeRaw;
  final String endTimeRaw;
  final String bookingName;
  final String bookingUnit;
  final bool isUpcomingTab;
  final String? lastScan;

  factory BookingListItem.fromResource(
    Map<String, dynamic> m, {
    required bool isUpcomingTab,
  }) {
    final types = m['types_by_type_uuid'];
    var category = '';
    if (types is Map) category = types['name']?.toString() ?? '';

    var name = 'N/A';
    var unit = 'N/A';
    final prof = m['user_profiles_by_user_profile_uuid'];
    if (prof is Map && prof['name'] != null) {
      name = prof['name'].toString();
    }
    final resUnit = m['residence_units_by_unit_uuid'];
    if (resUnit is Map && resUnit['name'] != null) {
      unit = resUnit['name'].toString();
    }

    return BookingListItem(
      uuid: m['uuid']?.toString() ?? '',
      roomName: m['room_name']?.toString() ?? '',
      category: category,
      startTimeRaw: m['start_time']?.toString() ?? '',
      endTimeRaw: m['end_time']?.toString() ?? '',
      bookingName: name,
      bookingUnit: unit,
      isUpcomingTab: isUpcomingTab,
      lastScan: m['last_scan']?.toString(),
    );
  }
}
