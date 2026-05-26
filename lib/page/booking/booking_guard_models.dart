/// Guard booking row from list or detail APIs.
class GuardBookingRow {
  const GuardBookingRow({
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
    this.etaArrivalLabel,
    this.etaExitLabel,
    this.qrCodeData,
    this.callPhone,
    this.attendeeCount,
    this.actualArrivalTime,
    this.actualExitTime,
    this.actualArrivalLabel,
    this.actualExitLabel,
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
  final String? etaArrivalLabel;
  final String? etaExitLabel;
  final String? qrCodeData;
  final String? callPhone;
  final int? attendeeCount;
  final String? actualArrivalTime;
  final String? actualExitTime;
  final String? actualArrivalLabel;
  final String? actualExitLabel;

  bool get canCheckIn => guardStatus == 'upcoming';

  bool get canCheckOut => guardStatus == 'checked_in';

  String get dialPhone {
    final p = callPhone;
    if (p != null && p.isNotEmpty) return p;
    return mobileNumber;
  }

  factory GuardBookingRow.fromJson(Map<String, dynamic> json) {
    final unit = json['unit'];
    final bookingTime = json['booking_time'];
    final time = bookingTime is Map<String, dynamic> ? bookingTime : null;
    return GuardBookingRow(
      id: json['id'] as int? ?? int.tryParse('${json['id']}') ?? 0,
      bookingNumber: json['booking_number']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobileNumber: json['mobile_number']?.toString() ?? '',
      unitLabel: unit is Map ? unit['display_label']?.toString() ?? '' : '',
      category: json['category']?.toString() ?? '',
      bookingName: json['booking_name']?.toString() ?? '',
      guardStatus: json['guard_status']?.toString() ?? '',
      timeRangeLabel: json['time_range_label']?.toString() ?? '',
      durationLabel: json['duration_label']?.toString() ?? '',
      submittedDate: json['submitted_date']?.toString() ?? '',
      etaArrivalLabel: json['eta_arrival_label']?.toString(),
      etaExitLabel: json['eta_exit_label']?.toString(),
      qrCodeData: json['qr_code_data']?.toString(),
      callPhone: json['call_phone']?.toString(),
      attendeeCount: json['attendee_count'] as int?,
      actualArrivalTime: json['actual_arrival_time']?.toString() ??
          time?['actual_arrival_time']?.toString(),
      actualExitTime: json['actual_exit_time']?.toString() ??
          time?['actual_exit_time']?.toString(),
      actualArrivalLabel: time?['eta_arrival_label']?.toString(),
      actualExitLabel: time?['eta_exit_label']?.toString(),
    );
  }
}

class GuardBookingListResult {
  const GuardBookingListResult({
    required this.date,
    required this.tab,
    required this.counts,
    required this.bookings,
  });

  final String date;
  final String tab;
  final GuardBookingCounts counts;
  final List<GuardBookingRow> bookings;
}

class GuardBookingCounts {
  const GuardBookingCounts({
    required this.allBookings,
    required this.checkedIn,
    required this.upcoming,
  });

  final int allBookings;
  final int checkedIn;
  final int upcoming;

  factory GuardBookingCounts.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GuardBookingCounts(allBookings: 0, checkedIn: 0, upcoming: 0);
    return GuardBookingCounts(
      allBookings: json['all_bookings'] as int? ?? 0,
      checkedIn: json['checked_in'] as int? ?? 0,
      upcoming: json['upcoming'] as int? ?? 0,
    );
  }
}
