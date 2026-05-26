import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/guard_api_message.dart';
import '../../core/guard_api_paths.dart';
import '../../core/guard_time_format.dart';
import '../../service/api_service.dart';
import '../attendance/attendance_model.dart';
import '../attendance/attendance_record_format.dart';
import 'guard_attendance_models.dart';

final guardAttendanceRepositoryProvider = Provider<GuardAttendanceRepository>(
  (ref) => GuardAttendanceRepository(ref.watch(dioProvider)),
);

class GuardAttendanceRepository {
  GuardAttendanceRepository(this._dio);

  final Dio _dio;

  Future<GuardAttendanceRecord> startShift({
    required String residenceUuid,
    required File selfie,
  }) async {
    final data = await _postShift(
      GuardApiPaths.attendanceStart(residenceUuid),
      selfie,
    );
    return _parseSingleAttendance(data);
  }

  Future<GuardAttendanceRecord> endShift({
    required String residenceUuid,
    required File selfie,
  }) async {
    final data = await _postShift(
      GuardApiPaths.attendanceEnd(residenceUuid),
      selfie,
    );
    return _parseSingleAttendance(data);
  }

  Future<List<GuardAttendanceRecord>> fetchAttendance({
    required String residenceUuid,
    required DateTime fromDay,
    required DateTime toDay,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      GuardApiPaths.attendanceList(residenceUuid),
      queryParameters: <String, dynamic>{
        'from': GuardTimeFormat.apiDate(fromDay),
        'to': GuardTimeFormat.apiDate(toDay),
      },
    );
    return _parseAttendanceList(res.data);
  }

  /// Android `FilterAttendance` with
  /// `((kg_guard_uuid=$guardUuid) AND (checkout_at is null))` — open shift for **this** guard.
  Future<bool> hasOpenShiftForGuard(
    String residenceUuid,
    String guardUuid,
  ) async {
    final now = DateTime.now();
    final list = await fetchAttendance(
      residenceUuid: residenceUuid,
      fromDay: DateTime(now.year - 1, 1, 1),
      toDay: now,
    );
    final open = list.where((r) => r.isOpen).toList();
    if (open.isEmpty) return false;
    final g = guardUuid.trim();
    if (g.isEmpty) return open.isNotEmpty;
    final anyTagged = open.any(
      (r) => r.guardUuid != null && r.guardUuid!.trim().isNotEmpty,
    );
    if (!anyTagged) {
      // API did not include per-row guard ids — list is assumed scoped to the session guard.
      return open.isNotEmpty;
    }
    return open.any(
      (r) => r.guardUuid != null &&
          r.guardUuid!.trim().toLowerCase() == g.toLowerCase(),
    );
  }

  List<AttendanceRecordRow> toRecordRows(
    List<GuardAttendanceRecord> list, {
    required String guardName,
  }) {
    return list.map((r) {
      final hasEnd = r.endedAt != null && r.endedAt!.isNotEmpty;
      return AttendanceRecordRow(
        uuid: r.id.toString(),
        guardName: guardName,
        imageUrl: (hasEnd ? r.endPhotoUrl : r.startPhotoUrl) ?? '',
        guardCode: '',
        checkInLabel: AttendanceRecordFormat.timeLabel(r.startedAt),
        checkOutLabel: hasEnd ? AttendanceRecordFormat.timeLabel(r.endedAt) : null,
        isCheckedInOnly: r.isOpen,
      );
    }).toList();
  }

  Future<Map<String, dynamic>> _postShift(String path, File selfie) async {
    final form = FormData.fromMap(<String, dynamic>{
      'current_time': GuardTimeFormat.shiftTimestamp(DateTime.now()),
      'selfie_photo': await MultipartFile.fromFile(
        selfie.path,
        filename: 'selfie.jpg',
      ),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      path,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? 'Request failed',
      );
    }
    final data = guardApiData(body);
    if (data == null) throw StateError('Invalid attendance payload');
    return data;
  }

  GuardAttendanceRecord _parseSingleAttendance(Map<String, dynamic> data) {
    final raw = data['attendance'];
    if (raw is Map<String, dynamic>) return GuardAttendanceRecord.fromJson(raw);
    throw StateError('Invalid attendance payload');
  }

  List<GuardAttendanceRecord> _parseAttendanceList(Map<String, dynamic>? body) {
    if (!guardApiSuccess(body)) {
      throw StateError(body?['message'] as String? ?? 'Failed to load attendance');
    }
    final data = guardApiData(body);
    final raw = data?['attendance'];
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GuardAttendanceRecord.fromJson)
        .toList();
  }
}
