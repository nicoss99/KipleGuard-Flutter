import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../service/api_service.dart';
import 'booking_filter_query.dart';

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepository(ref.watch(dioProvider)),
);

/// Android `RetrofitListAPI` booking APIs (`RetrofitInterface.kt`).
class BookingRepository {
  BookingRepository(this._dio);

  final Dio _dio;

  static const _relatedBookings =
      'visitors_by_booking_uuid,rooms_by_room_uuid,user_profiles_by_user_profile_uuid,types_by_type_uuid,residence_units_by_unit_uuid';

  String _utcDayStart(DateTime dayLocal) => DateFormat(
    'yyyy-MM-dd HH:mm:ss',
  ).format(DateTime(dayLocal.year, dayLocal.month, dayLocal.day).toUtc());

  String _utcDayEnd(DateTime dayLocal) =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(
        DateTime(
          dayLocal.year,
          dayLocal.month,
          dayLocal.day,
          23,
          59,
          59,
        ).toUtc(),
      );

  /// Checked-in list filter (`BookingCurrent` in `ListBookingActivity.refreshBookingList`).
  String listFilterCheckedIn({
    required String residenceUuid,
    required DateTime dayLocal,
    BookingFilterQuery query = BookingFilterQuery.empty,
    String searchQuery = '',
  }) {
    final trimmed = searchQuery.trim();
    if (query.active) {
      return _filterCheckedInFiltered(
        residenceUuid: residenceUuid,
        dayLocal: dayLocal,
        query: query,
      );
    }
    if (trimmed.length >= 3) {
      return '((is_cancelled=0) AND (is_active=1) AND (residence_uuid=$residenceUuid) '
          'AND ((user_name LIKE %$trimmed%) OR (unit_name LIKE %$trimmed%)) '
          'AND (last_scan=IN))';
    }
    final a = _utcDayStart(dayLocal);
    final b = _utcDayEnd(dayLocal);
    return '((is_cancelled=0) AND (is_active=1) AND (residence_uuid=$residenceUuid) '
        'AND (start_time>=$a) AND (end_time<=$b) AND (last_scan=IN))';
  }

  /// Upcoming list filter (`BookingUpcoming`).
  String listFilterUpcoming({
    required String residenceUuid,
    required DateTime dayLocal,
    BookingFilterQuery query = BookingFilterQuery.empty,
    String searchQuery = '',
  }) {
    final trimmed = searchQuery.trim();
    if (query.active) {
      return _filterUpcomingFiltered(
        residenceUuid: residenceUuid,
        dayLocal: dayLocal,
        query: query,
      );
    }
    if (trimmed.length >= 3) {
      return '((is_cancelled=0) AND (is_active=1) AND (residence_uuid=$residenceUuid) '
          'AND ((user_name LIKE %$trimmed%) OR (unit_name LIKE %$trimmed%)) '
          'AND ((last_scan is null) OR (last_scan=OUT)))';
    }
    final a = _utcDayStart(dayLocal);
    final b = _utcDayEnd(dayLocal);
    return '((is_cancelled=0) AND (is_active=1) AND (residence_uuid=$residenceUuid) '
        'AND (start_time>=$a) AND (start_time<=$b) AND (last_scan is null))';
  }

  String _filterCheckedInFiltered({
    required String residenceUuid,
    required DateTime dayLocal,
    required BookingFilterQuery query,
  }) {
    final rs = _utcDayStart(dayLocal);
    final re = _utcDayEnd(dayLocal);
    var fd = '';
    if (query.submittedOnDay != null) {
      final s = _utcDayStart(query.submittedOnDay!);
      final e = _utcDayEnd(query.submittedOnDay!);
      fd = 'AND (created_at>=$s) AND (created_at<=$e) ';
    }
    var fc = '';
    final cu = query.categoryUuid;
    if (cu != null && cu.isNotEmpty) {
      fc = 'AND (type_uuid=$cu) ';
    }
    var fr = '';
    final ru = query.roomUuid;
    if (ru != null && ru.isNotEmpty) {
      fr = 'AND (room_uuid=$ru) ';
    }
    return '((is_cancelled=0) AND (is_active=1) AND (residence_uuid=$residenceUuid) '
        'AND (start_time>=$rs) AND (start_time<=$re) '
        '$fd$fc$fr'
        'AND (last_scan=IN))';
  }

  String _filterUpcomingFiltered({
    required String residenceUuid,
    required DateTime dayLocal,
    required BookingFilterQuery query,
  }) {
    final rs = _utcDayStart(dayLocal);
    final re = _utcDayEnd(dayLocal);
    var fd = '';
    if (query.submittedOnDay != null) {
      final s = _utcDayStart(query.submittedOnDay!);
      final e = _utcDayEnd(query.submittedOnDay!);
      fd = 'AND (created_at>=$s) AND (created_at<=$e) ';
    }
    var fc = '';
    final cu = query.categoryUuid;
    if (cu != null && cu.isNotEmpty) {
      fc = 'AND (type_uuid=$cu) ';
    }
    var fr = '';
    final ru = query.roomUuid;
    if (ru != null && ru.isNotEmpty) {
      fr = 'AND (room_uuid=$ru) ';
    }
    return '((is_cancelled=0) AND (is_active=1) AND (residence_uuid=$residenceUuid) '
        'AND (start_time>=$rs) AND (start_time<=$re) '
        '$fd$fc$fr'
        'AND (last_scan is null))';
  }

  /// Android `bookingCategoryListAPI` — GET `data/types`.
  Future<List<({String uuid, String name})>> fetchBookingCategories(
    String residenceUuid,
  ) async {
    final filter = '((residence_uuid=$residenceUuid) AND (deleted_at is null))';
    final res = await _dio.get<dynamic>(
      'data/types',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'order': '',
        'related': 'files_by_file_uuid',
        'include_count': 'true',
        'offset': '0',
        'limit': '10000',
      },
    );
    return _extractResourceList(res.data)
        .map(
          (m) => (
            uuid: m['uuid']?.toString() ?? '',
            name: m['name']?.toString() ?? '',
          ),
        )
        .where((e) => e.uuid.isNotEmpty)
        .toList();
  }

  /// Android `bookingRoomListAPI` — POST `bookings/available`.
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
    final data = res.data;
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

  /// `bookingCurrentAPI` — GET `data/bookings`.
  Future<({List<Map<String, dynamic>> resources, int? count})>
  fetchBookingsPage({required String filter, required int offset}) async {
    final res = await _dio.get<dynamic>(
      'data/bookings',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'order': 'start_time DESC',
        'related': _relatedBookings,
        'include_count': 'true',
        'offset': '$offset',
        'limit': '10',
      },
    );
    final data = res.data;
    final list = _extractResourceList(data);
    final count = _metaCount(data);
    return (resources: list, count: count);
  }

  /// Single booking for detail (`ListBookingDetailsActivity` filter).
  Future<Map<String, dynamic>?> fetchBookingDetail({
    required String residenceUuid,
    required String bookingUuid,
  }) async {
    final filter =
        '((is_cancelled=0) AND (is_active=1) AND (residence_uuid=$residenceUuid) AND (uuid=$bookingUuid))';
    final r = await fetchBookingsPage(filter: filter, offset: 0);
    return r.resources.isEmpty ? null : r.resources.first;
  }

  /// Android `RetrofitListAPI.editbookingAPI` — PUT `data/bookings/{uuid}`.
  Future<void> editBooking({
    required String bookingUuid,
    String? checkInTimeUtc,
    String? checkOutTimeUtc,
    required String lastScan,
  }) async {
    final body = <String, dynamic>{'last_scan': lastScan};
    if (checkInTimeUtc != null && checkInTimeUtc.isNotEmpty) {
      body['check_in_time'] = checkInTimeUtc;
    }
    if (checkOutTimeUtc != null && checkOutTimeUtc.isNotEmpty) {
      body['check_out_time'] = checkOutTimeUtc;
    }
    await _dio.put<dynamic>('data/bookings/$bookingUuid', data: body);
  }
}

int? _metaCount(dynamic data) {
  if (data is! Map) return null;
  final m = data['meta'];
  if (m is Map && m['count'] != null) {
    return int.tryParse(m['count'].toString());
  }
  return null;
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
