import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/guard_api_message.dart';
import '../../core/residence_prefs.dart';
import '../../core/guard_api_paths.dart';
import '../../service/api_service.dart';
import '../visitor/visitor_model.dart';
import 'guard_visitor_day_result.dart';
import 'guard_visitor_mapper.dart';
final guardVisitorRepositoryProvider = Provider<GuardVisitorRepository>(
  (ref) => GuardVisitorRepository(ref.watch(dioProvider)),
);

class GuardVisitorListResult {
  const GuardVisitorListResult({required this.date, required this.items});

  final String date;
  final List<VisitorListItem> items;
}

class GuardVisitorScanResult {
  const GuardVisitorScanResult({required this.visitorId, this.raw});

  final int visitorId;
  final Map<String, dynamic>? raw;
}

class GuardVisitorRepository {
  GuardVisitorRepository(this._dio);

  final Dio _dio;

  static String _dateQuery(DateTime day) =>
      DateFormat('yyyy-MM-dd').format(DateTime(day.year, day.month, day.day));

  /// `GET api/v1/guard/residences/{uuid}/visitors?date=` — counts + visitors.
  Future<({String date, GuardVisitorCounts counts, List<VisitorListItem> items})>
      fetchVisitorsForDay(
    String residenceUuid, {
    required DateTime date,
  }) async {
    final data = await _getVisitorsPayload(
      residenceUuid,
      date: date,
      status: null,
    );
    final responseDate = data?['date']?.toString() ?? _dateQuery(date);
    final counts = GuardVisitorCounts.fromJson(
      data?['counts'] as Map<String, dynamic>?,
    );
    final items = await _parseVisitors(data?['visitors'], residenceUuid);
    return (date: responseDate, counts: counts, items: items);
  }

  /// `GET .../visitors?date=&status=` — same payload shape, filtered list.
  /// `GET api/v1/guard/residences/{uuid}/visitors/{id}`
  Future<Map<String, dynamic>?> fetchVisitorById(
    String residenceUuid, {
    required int visitorId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      GuardApiPaths.visitorDetail(residenceUuid, visitorId),
    );
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? 'Failed to load visitor',
      );
    }
    final data = guardApiData(body);
    final visitor = data?['visitor'];
    if (visitor is Map<String, dynamic>) return visitor;
    return null;
  }

  Future<GuardVisitorListResult> fetchVisitors(
    String residenceUuid, {
    required DateTime date,
    required String status,
  }) async {
    final data = await _getVisitorsPayload(
      residenceUuid,
      date: date,
      status: status,
    );
    final responseDate = data?['date']?.toString() ?? _dateQuery(date);
    final items = await _parseVisitors(data?['visitors'], residenceUuid);
    return GuardVisitorListResult(date: responseDate, items: items);
  }

  Future<Map<String, dynamic>?> _getVisitorsPayload(
    String residenceUuid, {
    required DateTime date,
    String? status,
  }) async {
    final query = <String, dynamic>{'date': _dateQuery(date)};
    if (status != null && status.isNotEmpty) query['status'] = status;

    final res = await _dio.get<Map<String, dynamic>>(
      GuardApiPaths.visitors(residenceUuid),
      queryParameters: query,
    );
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? 'Failed to load visitors',
      );
    }
    return guardApiData(body);
  }

  Future<List<VisitorListItem>> _parseVisitors(Object? raw, String residenceUuid) async {
    final activeUuid = residenceUuid.isNotEmpty
        ? residenceUuid
        : (await ResidencePrefs.readResidenceUuid()) ?? '';
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((m) => GuardVisitorMapper.mapVisitor(m, activeUuid))
        .toList();
  }

  Future<GuardVisitorScanResult> scanVisitor({
    required String residenceUuid,
    required String qrCodeData,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      GuardApiPaths.visitorScan(residenceUuid),
      data: <String, dynamic>{'qr_code_data': qrCodeData},
    );
    return _parseScan(res);
  }

  Future<void> checkIn({
    required String residenceUuid,
    required int visitorId,
  }) async {
    await _postVisitorAction(
      GuardApiPaths.visitorCheckIn(residenceUuid, visitorId),
    );
  }

  Future<void> checkOut({
    required String residenceUuid,
    required int visitorId,
  }) async {
    await _postVisitorAction(
      GuardApiPaths.visitorCheckOut(residenceUuid, visitorId),
    );
  }

  Future<void> _postVisitorAction(String path) async {
    final res = await _dio.post<Map<String, dynamic>>(path);
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? 'Request failed',
      );
    }
  }

  GuardVisitorScanResult _parseScan(Response<Map<String, dynamic>> res) {
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? 'Scan failed',
      );
    }
    final data = guardApiData(body);
    final visitor = data?['visitor'];
    if (visitor is Map<String, dynamic>) {
      final id = visitor['id'] as int? ?? visitor['visitor_id'] as int?;
      if (id != null) return GuardVisitorScanResult(visitorId: id, raw: visitor);
    }
    final id = data?['visitor_id'] as int? ?? data?['id'] as int?;
    if (id != null) return GuardVisitorScanResult(visitorId: id, raw: data);
    throw StateError('Invalid scan payload');
  }
}
