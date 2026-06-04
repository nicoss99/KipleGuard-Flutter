import 'attendance_record_format.dart';

/// One row for record list (Android `AttendanceObject`).
class AttendanceRecordRow {
  const AttendanceRecordRow({
    required this.uuid,
    required this.guardName,
    required this.imageUrl,
    required this.guardCode,
    required this.checkInAt,
    this.checkOutAt,
    required this.isCheckedInOnly,
  });

  final String uuid;
  final String guardName;
  final String imageUrl;
  final String guardCode;
  /// Raw API `started_at` — formatted at display time (MYT).
  final String checkInAt;
  /// Raw API `ended_at` — formatted at display time (MYT).
  final String? checkOutAt;
  final bool isCheckedInOnly;

  String get checkInDisplay => AttendanceRecordFormat.timeLabel(checkInAt);

  String? get checkOutDisplay {
    final raw = checkOutAt;
    if (raw == null || raw.trim().isEmpty) return null;
    final label = AttendanceRecordFormat.timeLabel(raw);
    return label.isEmpty ? null : label;
  }
}
