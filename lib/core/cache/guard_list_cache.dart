import '../guard_time_format.dart';
import '../../page/attendance/attendance_model.dart';
import '../../page/booking/booking_guard_models.dart';
import '../../page/visitor/visitor_model.dart';
import 'app_cache_store.dart';
import 'guard_cache_keys.dart';

/// Read/write cached guard list payloads (visitors, bookings, attendance).
abstract final class GuardListCache {
  static Future<void> saveVisitors({
    required String residenceUuid,
    required DateTime day,
    required String tabKey,
    required String responseDate,
    required int totalCheckIn,
    required int totalIncoming,
    required int totalOvertime,
    required int totalVisitors,
    required List<VisitorListItem> items,
    bool allOvertimeSection = false,
  }) async {
    final key = allOvertimeSection
        ? GuardCacheKeys.visitorsAllOvertime(residenceUuid)
        : GuardCacheKeys.visitors(residenceUuid, day, tabKey: tabKey);
    await AppCacheStore.write(
      key,
      <String, dynamic>{
        'responseDate': responseDate,
        'totalCheckIn': totalCheckIn,
        'totalIncoming': totalIncoming,
        'totalOvertime': totalOvertime,
        'totalVisitors': totalVisitors,
        'items': items.map(_visitorToJson).toList(),
      },
    );
  }

  static Future<VisitorCacheSnapshot?> readVisitors({
    required String residenceUuid,
    required DateTime day,
    required String tabKey,
    bool allOvertimeSection = false,
  }) async {
    final key = allOvertimeSection
        ? GuardCacheKeys.visitorsAllOvertime(residenceUuid)
        : GuardCacheKeys.visitors(residenceUuid, day, tabKey: tabKey);
    final env = await AppCacheStore.read(key);
    if (env == null) return null;
    final raw = env.data['items'];
    if (raw is! List) return null;
    final items = raw
        .whereType<Map>()
        .map((e) => _visitorFromJson(Map<String, dynamic>.from(e)))
        .toList();
    return VisitorCacheSnapshot(
      savedAt: env.savedAt,
      responseDate: env.data['responseDate']?.toString() ?? '',
      totalCheckIn: env.data['totalCheckIn'] as int? ?? 0,
      totalIncoming: env.data['totalIncoming'] as int? ?? 0,
      totalOvertime: env.data['totalOvertime'] as int? ?? 0,
      totalVisitors: env.data['totalVisitors'] as int? ?? 0,
      items: items,
    );
  }

  static Future<void> saveBookings({
    required String residenceUuid,
    required DateTime day,
    required String tab,
    required GuardBookingListResult result,
  }) async {
    await AppCacheStore.write(
      GuardCacheKeys.bookings(residenceUuid, day, tab),
      <String, dynamic>{
        'date': result.date,
        'tab': result.tab,
        'counts': <String, dynamic>{
          'all_bookings': result.counts.allBookings,
          'checked_in': result.counts.checkedIn,
          'upcoming': result.counts.upcoming,
        },
        'bookings': result.bookings.map(_bookingToJson).toList(),
      },
    );
  }

  static Future<BookingCacheSnapshot?> readBookings({
    required String residenceUuid,
    required DateTime day,
    required String tab,
  }) async {
    final env = await AppCacheStore.read(
      GuardCacheKeys.bookings(residenceUuid, day, tab),
    );
    if (env == null) return null;
    final raw = env.data['bookings'];
    if (raw is! List) return null;
    final bookings = raw
        .whereType<Map>()
        .map((e) => GuardBookingRow.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.id > 0)
        .toList();
    final countsRaw = env.data['counts'];
    return BookingCacheSnapshot(
      savedAt: env.savedAt,
      result: GuardBookingListResult(
        date: env.data['date']?.toString() ?? '',
        tab: env.data['tab']?.toString() ?? tab,
        counts: countsRaw is Map<String, dynamic>
            ? GuardBookingCounts.fromJson(countsRaw)
            : const GuardBookingCounts(allBookings: 0, checkedIn: 0, upcoming: 0),
        bookings: bookings,
      ),
    );
  }

  static Future<void> saveAttendance({
    required String residenceUuid,
    required DateTime day,
    required List<AttendanceRecordRow> records,
  }) async {
    await AppCacheStore.write(
      GuardCacheKeys.attendance(residenceUuid, day),
      <String, dynamic>{
        'records': records.map(_attendanceToJson).toList(),
      },
    );
  }

  static Future<AttendanceCacheSnapshot?> readAttendance({
    required String residenceUuid,
    required DateTime day,
  }) async {
    final env = await AppCacheStore.read(GuardCacheKeys.attendance(residenceUuid, day));
    if (env == null) return null;
    final raw = env.data['records'];
    if (raw is! List) return null;
    final records = raw
        .whereType<Map>()
        .map((e) => _attendanceFromJson(Map<String, dynamic>.from(e)))
        .toList();
    return AttendanceCacheSnapshot(savedAt: env.savedAt, records: records);
  }

  static Future<void> clearForResidence(String residenceUuid) async {
    await AppCacheStore.removeWhere(
      (k) => GuardCacheKeys.isGuardCacheKey(k) && GuardCacheKeys.matchesResidence(k, residenceUuid),
    );
  }

  static String formatSavedAt(DateTime at) =>
      GuardTimeFormat.displaySavedAt.format(at.toLocal());

  static Map<String, dynamic> _visitorToJson(VisitorListItem i) => <String, dynamic>{
        'uuid': i.uuid,
        'name': i.name,
        'unitLabel': i.unitLabel,
        'carPlate': i.carPlate,
        'passId': i.passId,
        'visitStatus': i.visitStatus,
        'latestScanType': i.latestScanType,
        'startTime': i.startTime,
        'qrCode': i.qrCode,
        'residenceUuid': i.residenceUuid,
        'createdByUuid': i.createdByUuid,
        'category': i.category.name,
      };

  static VisitorListItem _visitorFromJson(Map<String, dynamic> m) => VisitorListItem(
        uuid: m['uuid']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
        unitLabel: m['unitLabel']?.toString() ?? '',
        carPlate: m['carPlate']?.toString() ?? '',
        passId: m['passId']?.toString() ?? '',
        visitStatus: m['visitStatus']?.toString() ?? '',
        latestScanType: m['latestScanType']?.toString() ?? '',
        startTime: m['startTime']?.toString() ?? '',
        qrCode: m['qrCode']?.toString() ?? '',
        residenceUuid: m['residenceUuid']?.toString() ?? '',
        createdByUuid: m['createdByUuid']?.toString() ?? '',
        category: VisitorListCategory.values.byName(
          m['category']?.toString() ?? VisitorListCategory.upcoming.name,
        ),
      );

  static Map<String, dynamic> _bookingToJson(GuardBookingRow b) => b.toJson();

  static Map<String, dynamic> _attendanceToJson(AttendanceRecordRow r) =>
      <String, dynamic>{
        'uuid': r.uuid,
        'guardName': r.guardName,
        'imageUrl': r.imageUrl,
        'guardCode': r.guardCode,
        'checkInAt': r.checkInAt,
        'checkOutAt': r.checkOutAt,
        'isCheckedInOnly': r.isCheckedInOnly,
      };

  static AttendanceRecordRow _attendanceFromJson(Map<String, dynamic> m) =>
      AttendanceRecordRow(
        uuid: m['uuid']?.toString() ?? '',
        guardName: m['guardName']?.toString() ?? '',
        imageUrl: m['imageUrl']?.toString() ?? '',
        guardCode: m['guardCode']?.toString() ?? '',
        checkInAt: m['checkInAt']?.toString() ?? m['startedAt']?.toString() ?? '',
        checkOutAt: m['checkOutAt']?.toString() ?? m['endedAt']?.toString(),
        isCheckedInOnly: m['isCheckedInOnly'] == true,
      );
}

class VisitorCacheSnapshot {
  const VisitorCacheSnapshot({
    required this.savedAt,
    required this.responseDate,
    required this.totalCheckIn,
    required this.totalIncoming,
    required this.totalOvertime,
    required this.totalVisitors,
    required this.items,
  });

  final DateTime savedAt;
  final String responseDate;
  final int totalCheckIn;
  final int totalIncoming;
  final int totalOvertime;
  final int totalVisitors;
  final List<VisitorListItem> items;
}

class BookingCacheSnapshot {
  const BookingCacheSnapshot({required this.savedAt, required this.result});

  final DateTime savedAt;
  final GuardBookingListResult result;
}

class AttendanceCacheSnapshot {
  const AttendanceCacheSnapshot({required this.savedAt, required this.records});

  final DateTime savedAt;
  final List<AttendanceRecordRow> records;
}
