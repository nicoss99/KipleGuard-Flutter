import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api/client/dio_guard_http_client.dart';
import '../../core/api/client/guard_http_client.dart';
import '../../core/api/contracts/guard_booking_repository.dart' as contract;
import '../../core/guard_api_paths.dart';
import '../../core/guard_time_format.dart';
import 'booking_filter_models.dart';
import 'booking_guard_models.dart';
import 'booking_parsers.dart';
import 'booking_strings.dart';

final guardBookingRepositoryProvider = Provider<contract.GuardBookingRepository>(
  (ref) => GuardBookingRepositoryImpl(ref.watch(guardHttpClientProvider)),
);

final bookingRepositoryProvider = guardBookingRepositoryProvider;

final class GuardBookingRepositoryImpl implements contract.GuardBookingRepository {
  GuardBookingRepositoryImpl(this._client);

  final GuardHttpClient _client;
  static String _dateQuery(DateTime day) =>
      DateFormat('yyyy-MM-dd').format(DateTime(day.year, day.month, day.day));

  @override
  Future<GuardBookingListResult> fetchBookings({
    required String residenceUuid,
    required DateTime date,
    required BookingTabApi tab,
    int? samenityId,
    String? search,
  }) async {
    final query = <String, dynamic>{
      'date': _dateQuery(date),
      'tab': bookingTabApiValue(tab),
    };
    if (samenityId != null) query['samenity_id'] = samenityId;
    final q = search?.trim();
    if (q != null && q.length >= 3) query['search'] = q;

    final data = await _client.getJson(
      GuardApiPaths.bookings(residenceUuid),
      query: query,
      fallbackMessage: BookingStrings.loadFailed,
    );
    return parseBookingListFromApi(data);
  }

  @override
  Future<GuardBookingFilters> fetchBookingFilters({
    required String residenceUuid,
  }) async {
    final data = await _client.getJson(
      GuardApiPaths.bookingFilters(residenceUuid),
      fallbackMessage: BookingStrings.loadFailed,
    );
    return parseBookingFiltersFromApi(data);
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
}

String guardBookingCurrentTime([DateTime? when]) =>
    GuardTimeFormat.shiftTimestamp(when ?? DateTime.now());
