/// Row from `GET/POST .../attendance` guard APIs.
class GuardAttendanceRecord {
  const GuardAttendanceRecord({
    required this.id,
    required this.residenceId,
    required this.startedAt,
    this.endedAt,
    this.startPhotoUrl,
    this.endPhotoUrl,
    required this.isOpen,
    this.guardUuid,
  });

  final int id;
  final int residenceId;
  final String startedAt;
  final String? endedAt;
  final String? startPhotoUrl;
  final String? endPhotoUrl;
  final bool isOpen;
  /// Present when API tags rows — used for Android-style open-shift check per guard.
  final String? guardUuid;

  factory GuardAttendanceRecord.fromJson(Map<String, dynamic> json) =>
      GuardAttendanceRecord(
        id: json['id'] as int? ?? 0,
        residenceId: json['residence_id'] as int? ?? 0,
        startedAt: json['started_at'] as String? ?? '',
        endedAt: json['ended_at'] as String?,
        startPhotoUrl: json['start_photo_url'] as String?,
        endPhotoUrl: json['end_photo_url'] as String?,
        isOpen: json['is_open'] == true,
        guardUuid: _readGuardUuid(json),
      );
}

String? _readGuardUuid(Map<String, dynamic> json) {
  final direct = json['guard_uuid'] as String? ?? json['kg_guard_uuid'] as String?;
  if (direct != null && direct.trim().isNotEmpty) return direct.trim();
  final g = json['guard'];
  if (g is Map<String, dynamic>) {
    final u = g['uuid'] as String?;
    if (u != null && u.trim().isNotEmpty) return u.trim();
  }
  return null;
}