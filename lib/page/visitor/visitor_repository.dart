import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../service/api_service.dart';
import 'visitor_model.dart';

final visitorRepositoryProvider = Provider<VisitorRepository>(
  (ref) => VisitorRepository(ref.watch(dioProvider)),
);

class VisitorRepository {
  VisitorRepository(this._dio);

  final Dio _dio;

  static const _relatedList =
      'user_profiles_by_user_profile_uuid,residences_by_residence_uuid,residence_units_by_unit_uuid,files_by_photo,visitor_pass_scans_by_visitor_uuid';
  static const _relatedAllOvertime =
      'user_profiles_by_user_profile_uuid,residences_by_residence_uuid,residence_units_by_unit_uuid,files_by_photo,visitor_pass_scans_by_visitor_uuid';

  Future<VisitorListPageResult> fetchRevisedVisitors({
    required String filter,
    required VisitorListCategory category,
    int offset = 1,
    int limit = 5,
  }) async {
    final res = await _dio.get<dynamic>(
      'data-revise/visitors',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'order': 'start_time DESC',
        'related': _relatedList,
        'include_count': 'true',
        'offset': '$offset',
        'limit': '$limit',
      },
    );
    return _parseListPage(res.data, category);
  }

  Future<VisitorListPageResult> fetchAllOvertimeVisitors({
    required String residenceClause,
    int offset = 1,
    int limit = 10,
  }) async {
    final filter = '($residenceClause '
        "AND (status='VALID') "
        "AND (latest_scan_type='IN') "
        'AND (end_time < NOW())'
        'AND (deleted_at is NULL) '
        ')';
    final res = await _dio.get<dynamic>(
      'data-revise/visitors',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'order': 'start_time DESC',
        'related': _relatedAllOvertime,
        'include_count': 'true',
        'offset': '$offset',
        'limit': '$limit',
      },
    );
    return _parseListPage(res.data, VisitorListCategory.overtime);
  }

  Future<VisitorListPageResult> fetchUpcoming(String residenceUuid, {int offset = 1, int limit = 5}) async {
    final res = await _dio.get<dynamic>(
      'visitor/kiple-safe/upcoming',
      queryParameters: <String, dynamic>{
        'residence_uuid': residenceUuid,
        'order': 'start_time DESC',
        'offset': '$offset',
        'limit': '$limit',
      },
    );
    return _parseListPage(res.data, VisitorListCategory.upcoming);
  }

  Future<VisitorListPageResult> searchVisitors({
    required String residenceUuid,
    required String searchText,
    required String dateVisitUtc,
    int offset = 1,
    int limit = 5,
  }) async {
    final res = await _dio.get<dynamic>(
      'visit/kiple-safe/search',
      queryParameters: <String, dynamic>{
        'residence_uuid': residenceUuid,
        'search_text': searchText,
        'date_visit': dateVisitUtc,
        'offset': '$offset',
        'limit': '$limit',
      },
    );
    return _parseListPage(res.data, null);
  }

  Future<void> patchVisitor(String uuid, Map<String, dynamic> body) async {
    await _dio.patch<dynamic>('data/visitors/$uuid', data: body);
  }

  /// Android `RetrofitInterface.qr_check` — `POST qr/visitors/{qrcode}` with UTC `time` and weekday name.
  Future<void> qrVisitorScan({
    required String qrCodeRaw,
    required String residenceUuid,
    required String userProfileUuid,
  }) async {
    var code = qrCodeRaw.replaceAll('//', '').replaceAll(':', '').replaceAll('&', '').replaceAll('?', '');
    final weekday = _weekdayCalendarStyleEnglish();
    final timeUtc = _utcNowString();
    await _dio.post<dynamic>(
      'qr/visitors/$code',
      data: <String, dynamic>{
        'residence_uuid': residenceUuid,
        'weekday': weekday,
        'time': timeUtc,
        'user_profile': <String, dynamic>{'uuid': userProfileUuid},
      },
    );
  }
}

class VisitorListPageResult {
  const VisitorListPageResult({required this.items, this.total, this.pages});

  final List<VisitorListItem> items;
  final int? total;
  final int? pages;
}

VisitorListPageResult _parseListPage(dynamic data, VisitorListCategory? category) {
  final list = _extractResourceList(data);
  final items = <VisitorListItem>[];
  for (final m in list) {
    final row = _mapRow(m, category: category);
    if (row != null) items.add(row);
  }
  int? total;
  int? pages;
  if (data is Map<String, dynamic>) {
    final d = data['data'];
    if (d is Map<String, dynamic>) {
      total = (d['total'] as num?)?.toInt();
      pages = (d['pages'] as num?)?.toInt();
    }
  }
  return VisitorListPageResult(items: items, total: total, pages: pages);
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

VisitorListCategory _inferCategory(Map<String, dynamic> m) {
  final status = (m['status']?.toString() ?? '').toLowerCase();
  final visitStatus = (m['visit_status']?.toString() ?? '').toUpperCase();
  if (status == 'incoming' || visitStatus == 'CHECKEDIN') {
    return VisitorListCategory.upcoming;
  }
  if (status == 'checkin' || visitStatus == 'UPCOMING') {
    return VisitorListCategory.checkedIn;
  }
  if (status == 'overtime') return VisitorListCategory.overtime;
  final scan = (m['latest_scan_type']?.toString() ?? '').toUpperCase();
  return scan == 'IN' ? VisitorListCategory.checkedIn : VisitorListCategory.upcoming;
}

VisitorListItem? _mapRow(Map<String, dynamic> m, {VisitorListCategory? category}) {
  final uuid = m['uuid']?.toString() ?? '';
  if (uuid.isEmpty) return null;

  String pickNested(dynamic obj, List<String> keys) {
    if (obj is List && obj.isNotEmpty) {
      return pickNested(obj.first, keys);
    }
    if (obj is Map) {
      for (final k in keys) {
        final v = obj[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
    }
    return '';
  }

  final unitUuids = m['unit_uuids_by_unit_uuid'];
  final unitUuidsFirst = unitUuids is List && unitUuids.isNotEmpty ? unitUuids.first : null;
  final residenceUnit = m['residence_units_by_unit_uuid'];
  final residenceUnitLegacy = m['residence_unit'];

  var unit = m['unit_name']?.toString() ?? '';
  if (unit.trim().isEmpty) {
    unit = m['unit']?.toString() ?? '';
  }
  if (unit.trim().isEmpty) {
    unit = pickNested(unitUuidsFirst, ['unit', 'name', 'unit_name']);
  }
  if (unit.trim().isEmpty) {
    unit = pickNested(residenceUnit, ['unit', 'name', 'unit_name']);
  }
  if (unit.trim().isEmpty) {
    unit = pickNested(residenceUnitLegacy, ['unit', 'name', 'unit_name']);
  }

  var block = m['block_name']?.toString() ?? '';
  if (block.trim().isEmpty) {
    block = m['block']?.toString() ?? '';
  }
  if (block.trim().isEmpty) {
    block = pickNested(unitUuidsFirst, ['block', 'block_name', 'floor']);
  }
  if (block.trim().isEmpty) {
    block = pickNested(residenceUnit, ['block', 'block_name', 'floor']);
  }
  if (block.trim().isEmpty) {
    block = pickNested(residenceUnitLegacy, ['block', 'block_name', 'floor']);
  }

  final safeUnit = unit.trim().isEmpty ? 'N/A' : unit.trim();
  final safeBlock = block.trim().isEmpty ? '' : block.trim();
  final unitLabel = safeBlock.isNotEmpty ? '$safeBlock-$safeUnit' : safeUnit;
  return VisitorListItem(
    uuid: uuid,
    name: m['name']?.toString() ?? '',
    unitLabel: unitLabel,
    carPlate: m['car_plate_number']?.toString() ?? '',
    passId: m['pass_reference_id']?.toString() ?? '',
    visitStatus: m['visit_status']?.toString() ?? '',
    latestScanType: m['latest_scan_type']?.toString() ?? '',
    startTime: m['start_time']?.toString() ?? '',
    qrCode: m['qr_code']?.toString() ?? '',
    residenceUuid: m['residence_uuid']?.toString() ?? '',
    category: category ?? _inferCategory(m),
    createdByUuid: _parseCreatedByUuid(m),
  );
}

/// Android `VisitorDetailsActivity.scanQRcode` weekday from local `(Calendar.DAY_OF_WEEK - 1)`.
String _weekdayCalendarStyleEnglish() {
  final dow = DateTime.now().weekday % 7;
  const names = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
  return names[dow];
}

String _parseCreatedByUuid(Map<String, dynamic> m) {
  final c = m['created_by'];
  if (c == null) return '';
  if (c is String) return c.trim();
  if (c is Map) return c['uuid']?.toString().trim() ?? '';
  return c.toString().trim();
}

String _utcNowString() {
  final u = DateTime.now().toUtc();
  return '${u.year.toString().padLeft(4, '0')}-${_pad2(u.month)}-${_pad2(u.day)} ${_pad2(u.hour)}:${_pad2(u.minute)}:${_pad2(u.second)}';
}

String _pad2(int n) => n.toString().padLeft(2, '0');
