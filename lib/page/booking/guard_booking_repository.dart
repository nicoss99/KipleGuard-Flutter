import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api/client/dio_guard_http_client.dart';
import '../../core/api/client/guard_http_client.dart';
import '../../core/api/contracts/guard_booking_repository.dart' as contract;
import '../../core/guard_api_paths.dart';
import '../../core/guard_time_format.dart';
import '../../service/api_service.dart';
import 'booking_guard_models.dart';
import 'booking_parsers.dart';
import 'booking_strings.dart';

final guardBookingRepositoryProvider = Provider<contract.GuardBookingRepository>(
  (ref) => GuardBookingRepositoryImpl(
    ref.watch(guardHttpClientProvider),
    ref.watch(dioProvider),
  ),
);

final bookingRepositoryProvider = guardBookingRepositoryProvider;

final class GuardBookingRepositoryImpl implements contract.GuardBookingRepository {
  GuardBookingRepositoryImpl(this._client, this._dio);

  final GuardHttpClient _client;
  final Dio _dio;

  static String _dateQuery(DateTime day) =>
      DateFormat('yyyy-MM-dd').format(DateTime(day.year, day.month, day.day));

  @override
  Future<GuardBookingListResult> fetchBookings({
    required String residenceUuid,
    required DateTime date,
    required BookingTabApi tab,
  }) async {
    final data = await _client.getJson(
      GuardApiPaths.bookings(residenceUuid),
      query: <String, dynamic>{
        'date': _dateQuery(date),
        'tab': bookingTabApiValue(tab),
      },
      fallbackMessage: BookingStrings.loadFailed,
    );
    return parseBookingListFromApi(data);
  }

  @override
  Future<GuardBookingRow> fetchBookingDetail({
    required String residenceUuid,
    required int bookingId,
  }) async {
    final data = await _client.getJson(
      GuardApiPaths.bookingDetail(residenceUuid, bookingId),
      fallbackMessage: BookingStrings.loadFailed,
    );
    return parseBookingDetailFromApi(data);
  }

  @override
  Future<GuardBookingRow> checkIn({
    required String residenceUuid,
    required int bookingId,
    required String currentTime,
  }) async {
    final data = await _client.postJson(
      GuardApiPaths.bookingCheckIn(residenceUuid, bookingId),
      data: <String, dynamic>{'current_time': currentTime},
      fallbackMessage: BookingStrings.loadFailed,
    );
    return parseBookingDetailFromApi(data);
  }

  @override
  Future<GuardBookingRow> checkOut({
    required String residenceUuid,
    required int bookingId,
    required String currentTime,
  }) async {
    final data = await _client.postJson(
      GuardApiPaths.bookingCheckOut(residenceUuid, bookingId),
      data: <String, dynamic>{'current_time': currentTime},
      fallbackMessage: BookingStrings.loadFailed,
    );
    return parseBookingDetailFromApi(data);
  }

  @override
  Future<List<({String uuid, String name})>> fetchBookingCategories(
    String residenceUuid,
  ) async {
    final filter = '((residence_uuid=$residenceUuid) AND (deleted_at is null))';
    final data = await _client.getRaw(
      'data/types',
      query: <String, dynamic>{
        'filter': filter,
        'order': '',
        'related': 'files_by_file_uuid',
        'include_count': 'true',
        'offset': '0',
        'limit': '10000',
      },
    );
    return _extractResourceList(data)
        .map(
          (m) => (
            uuid: m['uuid']?.toString() ?? '',
            name: m['name']?.toString() ?? '',
          ),
        )
        .where((e) => e.uuid.isNotEmpty)
        .toList();
  }

  @override
  Future<List<({String uuid, String name})>> fetchRoomsForBookingType({
    required String residenceUuid,
    required String typeUuid,
  }) async {
    final res = await _dio.post<dynamic>(
      'bookings/available',
      data: <String, dynamic>{
        'type_uuid': typeUuid,
        'residence_uuid': residenceUuid,
      },
    );
    return _roomsFromAvailable(res.data);
  }

  List<({String uuid, String name})> _roomsFromAvailable(dynamic data) {
    if (data is! Map) return [];
    List<dynamic>? rbt = data['rooms_by_room_types'] as List<dynamic>?;
    rbt ??=
        (data['resource'] is Map
                ? (data['resource'] as Map)['rooms_by_room_types']
                : null)
            as List<dynamic>?;
    if (rbt == null) return [];
    final out = <({String uuid, String name})>[];
    for (final e in rbt) {
      if (e is Map) {
        final u = e['uuid']?.toString() ?? '';
        final n = e['name']?.toString() ?? '';
        if (u.isNotEmpty) out.add((uuid: u, name: n));
      }
    }
    return out;
  }
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

/// Guard check-in/out `current_time` for booking APIs.
String guardBookingCurrentTime([DateTime? when]) =>
    GuardTimeFormat.shiftTimestamp(when ?? DateTime.now());
