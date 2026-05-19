import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../service/api_service.dart';
import 'attendance_model.dart';
import 'attendance_record_format.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepository(ref.watch(dioProvider)),
);

/// Android `RetrofitListAPI` + `RetrofitInterface` attendance APIs
/// (`RetrofitListAPI.kt`, `RetrofitInterface.kt`, `AttendanceActivity.kt`).
class AttendanceRepository {
  AttendanceRepository(this._dio);

  final Dio _dio;

  static const _relatedList =
      'kg_guards_by_guard_uuid,residences_by_residence_uuid';

  /// Same `related` as Android `RetrofitListAPI.filterAttendanceListAPI`.
  static const _relatedFilterAttendance =
      'kg_guards_by_guard_uuid,residences_by_residence_uuid';

  /// Android `RetrofitListAPI.guardPinAPI` → `RetrofitInterface.guard_pin` — GET `data/kg_guards`.
  static const _relatedGuardPin =
      'kg_residence_guards_by_guard_uuid,kg_security_companies_by_security_company_uuid,residences_by_kg_residence_guards,residences_by_kg_attendances,kg_attendances_by_guard_uuid';

  /// `RetrofitListAPI.attendanceListAPI` — GET `data/kg_attendances`.
  Future<List<AttendanceRecordRow>> fetchAttendanceForDay({
    required String residenceUuid,
    required DateTime dayLocal,
  }) async {
    final bounds = _dayBoundsUtcStrings(dayLocal);
    final filter =
        "((residence_uuid=$residenceUuid) AND (checkin_at >= ${bounds.start}) AND (checkin_at <= ${bounds.end})) "
        'OR ((residence_uuid=$residenceUuid) AND (checkout_at >= ${bounds.start}) AND (checkout_at <= ${bounds.end}))';
    final res = await _dio.get<dynamic>(
      'data/kg_attendances',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'order': 'created_at DESC',
        'related': _relatedList,
        'include_count': 'true',
        'offset': '0',
        'limit': '10000',
      },
    );
    return _parseRecords(res.data);
  }

  /// Android `RetrofitListAPI.filterAttendanceListAPI` → `RetrofitInterface.filter_attendance`.
  /// GET `data/kg_attendances?filter=...&related=...` — open rows for guard (`checkout_at is null`).
  Future<List<Map<String, dynamic>>> filterAttendanceListApi(
    String guardUuid,
  ) async {
    final filter = '((kg_guard_uuid=$guardUuid) AND (checkout_at is null))';
    final res = await _dio.get<dynamic>(
      'data/kg_attendances',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'related': _relatedFilterAttendance,
      },
    );
    return _extractResourceList(res.data);
  }

  /// Android `RetrofitListAPI.guardPinAPI` — guards for security company (PIN + residence links).
  Future<List<Map<String, dynamic>>> fetchGuardsForPinValidation(
    String securityCompanyUuid,
  ) async {
    final filter = '((security_company_uuid=$securityCompanyUuid))';
    final res = await _dio.get<dynamic>(
      'data/kg_guards',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'related': _relatedGuardPin,
      },
    );
    return _extractResourceList(res.data);
  }

  /// Android `RetrofitInterface.attendance_file` — multipart `kgapi/files/Kgguards/{remotefile}`.
  Future<String> uploadAttendancePhoto(File file) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}';
    final part = await MultipartFile.fromFile(file.path, filename: '$name.jpg');
    final form = FormData.fromMap(<String, dynamic>{'file': part});
    final res = await _dio.post<dynamic>(
      'kgapi/files/Kgguards/$name',
      queryParameters: <String, dynamic>{'uuid': name},
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return _parseUploadUrl(res.data);
  }

  /// Android `AttendanceActivity` "CheckIn" → `RetrofitInterface.submit_checkin`.
  Future<void> submitCheckIn({
    required String residenceUuid,
    required String guardUuid,
    required String companyUuid,
    required double lat,
    required double lng,
    required String photoUrl,
  }) async {
    await _dio.post<dynamic>(
      'data/kg_attendances',
      data: <String, dynamic>{
        'residence_uuid': residenceUuid,
        'kg_guard_uuid': guardUuid,
        'security_company_uuid': companyUuid,
        'checkin_lat': lat,
        'checkin_lng': lng,
        'checkin_photo_url': photoUrl,
      },
    );
  }

  /// Android `AttendanceActivity` "CheckOut" → `RetrofitInterface.submit_checkout`.
  Future<void> submitCheckOut({
    required String guardUuid,
    required double lat,
    required double lng,
    required String photoUrl,
  }) async {
    final filter = '((kg_guard_uuid=$guardUuid) AND (checkout_at is null))';
    await _dio.patch<dynamic>(
      'data/kg_attendances',
      queryParameters: <String, dynamic>{'filter': filter},
      data: <String, dynamic>{
        'resource': <String, dynamic>{
          'checkout_lat': lat,
          'checkout_lng': lng,
          'checkout_photo_url': photoUrl,
        },
      },
    );
  }
}

({String start, String end}) _dayBoundsUtcStrings(DateTime dayLocal) {
  final startLocal = DateTime(dayLocal.year, dayLocal.month, dayLocal.day);
  final endLocal = DateTime(
    dayLocal.year,
    dayLocal.month,
    dayLocal.day,
    23,
    59,
    59,
  );
  final fmt = DateFormat('yyyy-MM-dd HH:mm:ss');
  final startUtc = fmt.format(startLocal.toUtc());
  final endUtc = fmt.format(endLocal.toUtc());
  return (start: startUtc, end: endUtc);
}

List<Map<String, dynamic>> _extractResourceList(dynamic data) {
  if (data is! Map) return [];
  final inner = data['data'];
  if (inner is Map && inner['list'] is List) {
    return _mapList(inner['list'] as List<dynamic>);
  }
  final res = data['resource'];
  if (res is List<dynamic>) return _mapList(res);
  return [];
}

List<Map<String, dynamic>> _mapList(List<dynamic> raw) {
  final out = <Map<String, dynamic>>[];
  for (final e in raw) {
    if (e is Map<String, dynamic>) {
      out.add(e);
    } else if (e is Map) {
      out.add(Map<String, dynamic>.from(e));
    }
  }
  return out;
}

List<AttendanceRecordRow> _parseRecords(dynamic data) {
  final list = _extractResourceList(data);

  final rows = <AttendanceRecordRow>[];
  for (final m in list) {
    final uuid = m['uuid']?.toString() ?? '';
    if (uuid.isEmpty) continue;
    final checkinAt = m['checkin_at']?.toString();
    final checkoutAt = m['checkout_at']?.toString();
    final hasCheckout =
        checkoutAt != null && checkoutAt.isNotEmpty && checkoutAt != 'null';
    var image = hasCheckout
        ? m['checkout_photo_url']?.toString()
        : m['checkin_photo_url']?.toString();
    image ??= m['checkin_photo_url']?.toString();
    image ??= '';

    final guard = m['kg_guards_by_guard_uuid'] ?? m['kg_guard'];
    var name = m['guard_name']?.toString() ?? '';
    var code = '';
    if (guard is Map) {
      if (name.isEmpty) name = guard['name']?.toString() ?? '';
      code = guard['guard_id']?.toString() ?? '';
    }

    rows.add(
      AttendanceRecordRow(
        uuid: uuid,
        guardName: name,
        imageUrl: image,
        guardCode: code,
        checkInLabel: AttendanceRecordFormat.timeLabel(checkinAt),
        checkOutLabel: hasCheckout ? AttendanceRecordFormat.timeLabel(checkoutAt) : null,
        isCheckedInOnly: !hasCheckout,
      ),
    );
  }
  return rows;
}

String _parseUploadUrl(dynamic data) {
  if (data is Map) {
    final u = data['url'] ?? data['path'] ?? data['file_url'];
    if (u is String && u.isNotEmpty) return u;
    final r = data['resource'];
    if (r is Map) {
      final u2 = r['url'] ?? r['path'];
      if (u2 is String && u2.isNotEmpty) return u2;
    }
  }
  developer.log(
    'Attendance upload: unexpected body $data',
    name: 'KipleGuard.Attendance',
  );
  throw StateError('Upload response missing url');
}
