import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api/client/dio_guard_http_client.dart';
import '../../core/api/client/guard_http_client.dart';
import '../../core/api/contracts/guard_attendance_repository.dart';
import '../../core/api/messages/api_message_catalog.dart';
import '../../core/api/messages/localized_api_message_catalog.dart';
import '../../core/guard_api_paths.dart';
import '../../core/guard_time_format.dart';
import '../attendance/attendance_model.dart';
import '../attendance/attendance_record_format.dart';
import 'guard_attendance_models.dart';

final guardAttendanceRepositoryProvider = Provider<GuardAttendanceRepository>(
  (ref) => GuardAttendanceRepositoryImpl(
    ref.watch(guardHttpClientProvider),
    ref.watch(apiMessageCatalogProvider),
  ),
);

final class GuardAttendanceRepositoryImpl implements GuardAttendanceRepository {
  GuardAttendanceRepositoryImpl(this._client, this._messages);

  final GuardHttpClient _client;
  final ApiMessageCatalog _messages;

  @override
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

  @override
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

  @override
  Future<List<GuardAttendanceRecord>> fetchAttendance({
    required String residenceUuid,
    required DateTime fromDay,
    required DateTime toDay,
  }) async {
    final data = await _client.getJson(
      GuardApiPaths.attendanceList(residenceUuid),
      query: <String, dynamic>{
        'from': GuardTimeFormat.apiDate(fromDay),
        'to': GuardTimeFormat.apiDate(toDay),
      },
      fallbackMessage: _messages.attendanceLoadFailed,
    );
    return _parseAttendanceList(data);
  }

  @override
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
    if (!anyTagged) return open.isNotEmpty;
    return open.any(
      (r) =>
          r.guardUuid != null &&
          r.guardUuid!.trim().toLowerCase() == g.toLowerCase(),
    );
  }

  @override
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
        checkOutLabel:
            hasEnd ? AttendanceRecordFormat.timeLabel(r.endedAt) : null,
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
    final data = await _client.postMultipart(
      path,
      data: form,
      fallbackMessage: _messages.requestFailed,
    );
    if (data == null) throw StateError(_messages.invalidAttendancePayload);
    return data;
  }

  GuardAttendanceRecord _parseSingleAttendance(Map<String, dynamic> data) {
    final raw = data['attendance'];
    if (raw is Map<String, dynamic>) return GuardAttendanceRecord.fromJson(raw);
    throw StateError(_messages.invalidAttendancePayload);
  }

  List<GuardAttendanceRecord> _parseAttendanceList(Map<String, dynamic>? data) {
    final raw = data?['attendance'];
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GuardAttendanceRecord.fromJson)
        .toList();
  }
}
