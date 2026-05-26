import 'package:intl/intl.dart';

/// Stable cache keys scoped by residence (and date/tab where needed).
abstract final class GuardCacheKeys {
  static const _prefix = 'kiple_guard_cache_';

  static String visitors(String residenceUuid, DateTime day) =>
      '${_prefix}visitors_${residenceUuid}_${DateFormat('yyyy-MM-dd').format(day)}';

  static String bookings(String residenceUuid, DateTime day, String tab) =>
      '${_prefix}bookings_${residenceUuid}_${DateFormat('yyyy-MM-dd').format(day)}_$tab';

  static String attendance(String residenceUuid, DateTime day) =>
      '${_prefix}attendance_${residenceUuid}_${DateFormat('yyyy-MM-dd').format(day)}';

  static String incidentTypes(String residenceUuid) =>
      '${_prefix}incident_types_$residenceUuid';

  static String callHistory(String residenceUuid) =>
      '${_prefix}call_history_$residenceUuid';

  static String unitCallDirectory(String residenceUuid) =>
      '${_prefix}unit_call_$residenceUuid';

  /// Legacy call-history key before [AppCacheStore] envelope migration.
  static String legacyCallHistory(String residenceUuid) =>
      'kiple_call_history_$residenceUuid';

  static String visitorDetail(String residenceUuid, int visitorId) =>
      '${_prefix}visitor_${residenceUuid}_$visitorId';

  static String bookingDetail(String residenceUuid, int bookingId) =>
      '${_prefix}booking_${residenceUuid}_$bookingId';

  static const guardProfile = '${_prefix}guard_profile';

  static bool isGuardCacheKey(String key) => key.startsWith(_prefix);

  static bool matchesResidence(String key, String residenceUuid) =>
      residenceUuid.isNotEmpty && key.contains(residenceUuid);
}
