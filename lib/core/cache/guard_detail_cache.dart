import '../../page/auth/guard_models.dart';
import '../../page/booking/booking_guard_models.dart';
import 'app_cache_store.dart';
import 'guard_cache_keys.dart';

/// Cached guard detail payloads (visitor, booking, profile).
abstract final class GuardDetailCache {
  static Future<void> saveVisitorDetail({
    required String residenceUuid,
    required int visitorId,
    required Map<String, dynamic> visitorJson,
    String residenceName = '',
  }) async {
    await AppCacheStore.write(
      GuardCacheKeys.visitorDetail(residenceUuid, visitorId),
      <String, dynamic>{
        'visitor': visitorJson,
        'residenceName': residenceName,
      },
    );
  }

  static Future<({DateTime savedAt, Map<String, dynamic> visitor, String residenceName})?>
      readVisitorDetail({
    required String residenceUuid,
    required int visitorId,
  }) async {
    final env = await AppCacheStore.read(
      GuardCacheKeys.visitorDetail(residenceUuid, visitorId),
    );
    if (env == null) return null;
    final visitor = env.data['visitor'];
    if (visitor is! Map) return null;
    return (
      savedAt: env.savedAt,
      visitor: Map<String, dynamic>.from(visitor),
      residenceName: env.data['residenceName']?.toString() ?? '',
    );
  }

  static Future<void> saveBookingDetail({
    required String residenceUuid,
    required int bookingId,
    required Map<String, dynamic> bookingJson,
  }) async {
    await AppCacheStore.write(
      GuardCacheKeys.bookingDetail(residenceUuid, bookingId),
      <String, dynamic>{'booking': bookingJson},
    );
  }

  static Future<({DateTime savedAt, GuardBookingRow row})?> readBookingDetail({
    required String residenceUuid,
    required int bookingId,
  }) async {
    final env = await AppCacheStore.read(
      GuardCacheKeys.bookingDetail(residenceUuid, bookingId),
    );
    if (env == null) return null;
    final raw = env.data['booking'];
    if (raw is! Map) return null;
    final row = GuardBookingRow.fromJson(Map<String, dynamic>.from(raw));
    if (row.id <= 0) return null;
    return (savedAt: env.savedAt, row: row);
  }

  static Future<void> saveGuardProfile({
    required GuardProfile guard,
    required List<GuardResidence> residences,
  }) async {
    await AppCacheStore.write(
      GuardCacheKeys.guardProfile,
      <String, dynamic>{
        'guard': guard.toJson(),
        'residences': residences.map((r) => r.toJson()).toList(),
      },
    );
  }

  static Future<({DateTime savedAt, GuardProfile guard, List<GuardResidence> residences})?>
      readGuardProfile() async {
    final env = await AppCacheStore.read(GuardCacheKeys.guardProfile);
    if (env == null) return null;
    final guardRaw = env.data['guard'];
    if (guardRaw is! Map) return null;
    final residencesRaw = env.data['residences'];
    final residences = residencesRaw is List
        ? residencesRaw
            .whereType<Map>()
            .map((e) => GuardResidence.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <GuardResidence>[];
    return (
      savedAt: env.savedAt,
      guard: GuardProfile.fromJson(Map<String, dynamic>.from(guardRaw)),
      residences: residences,
    );
  }
}
