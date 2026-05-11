/// One row for record list (Android `AttendanceObject`).
class AttendanceRecordRow {
  const AttendanceRecordRow({
    required this.uuid,
    required this.guardName,
    required this.imageUrl,
    required this.guardCode,
    required this.checkInLabel,
    required this.checkOutLabel,
    required this.isCheckedInOnly,
  });

  final String uuid;
  final String guardName;
  final String imageUrl;
  final String guardCode;
  final String checkInLabel;
  final String? checkOutLabel;
  final bool isCheckedInOnly;
}
