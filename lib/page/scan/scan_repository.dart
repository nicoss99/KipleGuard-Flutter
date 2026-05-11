import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../service/api_service.dart';

final scanRepositoryProvider = Provider<ScanRepository>(
  (ref) => ScanRepository(ref.watch(dioProvider)),
);

/// Android `RetrofitListAPI` / `RetrofitInterface` used from [QRScanActivity].
class ScanRepository {
  ScanRepository(this._dio);

  final Dio _dio;

  /// `GET visit/scan-qr/{residenceuuid}/{qrcode}` → first `data.list[].uuid`.
  Future<String?> scanQrVisitorUuid({
    required String residenceUuid,
    required String qrRaw,
  }) async {
    final q = Uri.encodeComponent(qrRaw);
    try {
      final res = await _dio.get<dynamic>('visit/scan-qr/$residenceUuid/$q');
      return _firstUuidFromDataList(res.data);
    } on DioException {
      return null;
    }
  }

  String? _firstUuidFromDataList(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final d = data['data'];
    if (d is! Map<String, dynamic>) return null;
    final list = d['list'];
    if (list is! List<dynamic> || list.isEmpty) return null;
    final first = list.first;
    if (first is! Map) return null;
    final u = first['uuid']?.toString();
    if (u == null || u.isEmpty) return null;
    return u;
  }

  /// `bookingCurrentAPI` filter from [QRScanActivity].
  Future<List<Map<String, dynamic>>> fetchBookingsByQr({
    required String residenceUuid,
    required String qr,
  }) async {
    final filter = '((is_cancelled=0) AND (residence_uuid=$residenceUuid) AND (qr_code=$qr))';
    final res = await _dio.get<dynamic>(
      'data/bookings',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'order': 'start_time DESC',
        'related':
            'visitors_by_booking_uuid,rooms_by_room_uuid,user_profiles_by_user_profile_uuid,types_by_type_uuid,residence_units_by_unit_uuid',
        'include_count': 'true',
        'offset': '0',
        'limit': '10',
      },
    );
    return _resourceList(res.data);
  }

  /// `formListAPI` — GET `data/applications`.
  Future<List<Map<String, dynamic>>> fetchApplications({
    required String filter,
  }) async {
    final res = await _dio.get<dynamic>(
      'data/applications',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'order': 'created_at DESC',
        'related': 'application_types_by_application_type_uuid,application_forms_by_application_form_uuid',
        'include_count': '',
        'offset': '0',
        'limit': '10000',
      },
    );
    return _resourceList(res.data);
  }

  /// `getUserTempAPI` — POST `healthcode/temperature`.
  Future<Map<String, dynamic>?> postHealthTemperatureLookup(Map<String, dynamic> body) async {
    final res = await _dio.post<dynamic>('healthcode/temperature', data: body);
    return res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : null;
  }

  /// `getGuardianAPI` — GET `data/guardian_parent_listing`.
  Future<List<Map<String, dynamic>>> fetchGuardianParent({
    required String filter,
  }) async {
    final res = await _dio.get<dynamic>(
      'data/guardian_parent_listing',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'order': '',
        'related': '',
        'include_count': 'true',
        'offset': '0',
        'limit': '10000',
      },
    );
    return _resourceList(res.data);
  }

  /// `getGuardianStudentAPI` — GET `data/students`.
  Future<List<Map<String, dynamic>>> fetchGuardianStudent({
    required String filter,
  }) async {
    final res = await _dio.get<dynamic>(
      'data/students',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'order': '',
        'related': 'classes_by_class_uuid,school_years_by_year_id',
        'include_count': 'true',
        'offset': '0',
        'limit': '10000',
      },
    );
    return _resourceList(res.data);
  }
}

List<Map<String, dynamic>> _resourceList(dynamic data) {
  if (data is! Map<String, dynamic>) return [];
  final res = data['resource'];
  if (res is! List<dynamic>) return [];
  return res
      .map((e) => e is Map<String, dynamic> ? e : (e is Map ? Map<String, dynamic>.from(e) : null))
      .whereType<Map<String, dynamic>>()
      .toList();
}

/// Comma-separated QR segments in Android order (residence, unit, profile, fr, parent…).
List<String> splitQrCsv(String qr) {
  try {
    return qr.split(',').map((e) => e.trim()).toList();
  } catch (_) {
    return [];
  }
}

/// Android `QRScanActivity` `filterResidence` for HDF form list.
String buildFormResidenceFilter({
  required String residenceUuid,
  required String officeEnable,
  required String buildingResidencesJson,
}) {
  final office = officeEnable.trim().toLowerCase();
  if (office != 'building') return '(residence_uuid=$residenceUuid)';
  var filter = '((residence_uuid=$residenceUuid)';
  if (buildingResidencesJson.isNotEmpty && buildingResidencesJson != 'null' && buildingResidencesJson != '[]') {
    try {
      final arr = jsonDecode(buildingResidencesJson);
      if (arr is List<dynamic>) {
        for (final item in arr) {
          if (item is! String || item.isEmpty) continue;
          final m = jsonDecode(item);
          if (m is Map && m['company_uuid'] != null) {
            filter += ' OR (residence_uuid=${m['company_uuid']})';
          }
        }
      }
    } catch (_) {}
  }
  if (filter.contains('((')) filter += ')';
  return filter;
}
