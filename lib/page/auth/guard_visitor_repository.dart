import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api/client/dio_guard_http_client.dart';
import '../../core/api/client/guard_http_client.dart';
import '../../core/api/contracts/guard_visitor_repository.dart' as contract;
import '../../core/api/messages/api_message_catalog.dart';
import '../../core/api/messages/localized_api_message_catalog.dart';
import '../../core/guard_api_message.dart';
import '../../core/guard_api_paths.dart';
import '../../core/residence_prefs.dart';
import '../visitor/visitor_model.dart';
import 'guard_visitor_day_result.dart';
import 'guard_visitor_list_parser.dart';
import 'guard_visitor_mapper.dart';

final guardVisitorRepositoryProvider = Provider<contract.GuardVisitorRepository>(
  (ref) => GuardVisitorRepository(
    ref.watch(guardHttpClientProvider),
    ref.watch(apiMessageCatalogProvider),
  ),
);

class GuardVisitorScanResult {
  const GuardVisitorScanResult({required this.visitorId, this.raw});

  final int visitorId;
  final Map<String, dynamic>? raw;
}

final class GuardVisitorRepository implements contract.GuardVisitorRepository {
  GuardVisitorRepository(this._client, this._messages);

  final GuardHttpClient _client;
  final ApiMessageCatalog _messages;

  static String _dateQuery(DateTime day) =>
      DateFormat('yyyy-MM-dd').format(DateTime(day.year, day.month, day.day));

  @override
  Future<({String date, GuardVisitorCounts counts, List<VisitorListItem> items})>
      fetchVisitorsForDay(
    String residenceUuid, {
    required DateTime date,
  }) =>
      fetchVisitors(residenceUuid, date: date);

  @override
  Future<({String date, GuardVisitorCounts counts, List<VisitorListItem> items})>
      fetchVisitors(
    String residenceUuid, {
    DateTime? date,
    String? status,
  }) async {
    final data = await _getVisitorsPayload(
      residenceUuid,
      date: date,
      status: status,
    );
    final responseDate = data?['date']?.toString() ??
        (date != null ? _dateQuery(date) : '');
    final counts = GuardVisitorCounts.fromJson(
      data?['counts'] as Map<String, dynamic>?,
    );
    final listCategory = GuardVisitorMapper.listCategoryForApiStatus(status);
    final items = await _parseVisitors(
      visitorListFromPayload(data, requestedStatus: status),
      residenceUuid,
      listCategory: listCategory,
    );
    return (date: responseDate, counts: counts, items: items);
  }

  @override
  Future<Map<String, dynamic>?> fetchVisitorById(
    String residenceUuid, {
    required int visitorId,
  }) async {
    final data = await _client.getJson(
      GuardApiPaths.visitorDetail(residenceUuid, visitorId),
      fallbackMessage: _messages.visitorDetailLoadFailed,
    );
    final visitor = data?['visitor'];
    if (visitor is Map<String, dynamic>) return visitor;
    return null;
  }

  @override
  Future<GuardVisitorScanResult> scanVisitor({
    required String residenceUuid,
    required String qrCodeData,
  }) async {
    final data = await _client.postJson(
      GuardApiPaths.visitorScan(residenceUuid),
      data: <String, dynamic>{'qr_code_data': qrCodeData},
      fallbackMessage: _messages.scanFailed,
    );
    return _parseScanData(data);
  }

  @override
  Future<void> checkIn({
    required String residenceUuid,
    required int visitorId,
  }) async {
    await _client.postJson(
      GuardApiPaths.residenceCheckIn(residenceUuid),
      data: <String, dynamic>{'visitor_id': visitorId},
      fallbackMessage: _messages.requestFailed,
    );
  }

  @override
  Future<void> checkOut({
    required String residenceUuid,
    required int visitorId,
  }) async {
    await _postVisitorAction(
      GuardApiPaths.visitorCheckOut(residenceUuid, visitorId),
    );
  }

  Future<Map<String, dynamic>?> _getVisitorsPayload(
    String residenceUuid, {
    DateTime? date,
    String? status,
  }) async {
    final query = <String, dynamic>{};
    if (date != null) query['date'] = _dateQuery(date);
    if (status != null && status.isNotEmpty) query['status'] = status;
    final body = await _client.getJson(
      GuardApiPaths.visitors(residenceUuid),
      query: query,
      fallbackMessage: _messages.visitorLoadFailed,
    );
    final data = guardApiData(body) ?? body;
    return data;
  }

  Future<List<VisitorListItem>> _parseVisitors(
    List<dynamic>? raw,
    String residenceUuid, {
    VisitorListCategory? listCategory,
  }) async {
    final activeUuid = residenceUuid.isNotEmpty
        ? residenceUuid
        : (await ResidencePrefs.readResidenceUuid()) ?? '';
    if (raw == null) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (m) => GuardVisitorMapper.mapVisitor(
            m,
            activeUuid,
            listCategory: listCategory,
          ),
        )
        .toList();
  }

  Future<void> _postVisitorAction(String path) async {
    await _client.postJson(path, fallbackMessage: _messages.requestFailed);
  }

  GuardVisitorScanResult _parseScanData(Map<String, dynamic>? data) {
    final visitor = data?['visitor'];
    if (visitor is Map<String, dynamic>) {
      final id = visitor['id'] as int? ?? visitor['visitor_id'] as int?;
      if (id != null) return GuardVisitorScanResult(visitorId: id, raw: visitor);
    }
    final id = data?['visitor_id'] as int? ?? data?['id'] as int?;
    if (id != null) return GuardVisitorScanResult(visitorId: id, raw: data);
    throw StateError(_messages.scanFailed);
  }
}
