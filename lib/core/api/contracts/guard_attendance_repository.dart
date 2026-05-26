import 'dart:io';

import '../../../page/attendance/attendance_model.dart';
import '../../../page/auth/guard_attendance_models.dart';

/// Guard attendance API (start/end shift, list, open-shift check).
abstract interface class GuardAttendanceRepository {
  Future<GuardAttendanceRecord> startShift({
    required String residenceUuid,
    required File selfie,
  });

  Future<GuardAttendanceRecord> endShift({
    required String residenceUuid,
    required File selfie,
  });

  Future<List<GuardAttendanceRecord>> fetchAttendance({
    required String residenceUuid,
    required DateTime fromDay,
    required DateTime toDay,
  });

  Future<bool> hasOpenShiftForGuard(String residenceUuid, String guardUuid);

  List<AttendanceRecordRow> toRecordRows(
    List<GuardAttendanceRecord> list, {
    required String guardName,
  });
}
