/// Guard API path builders (`/api/v1/guard/...`).
abstract final class GuardApiPaths {
  static const residences = 'api/v1/guard/residences';
  static const login = 'api/v1/guard/auth/login';
  static const logout = 'api/v1/guard/auth/logout';
  static const changePassword = 'api/v1/guard/auth/change-password';
  static const me = 'api/v1/guard/me';

  static String attendanceStart(String residenceUuid) =>
      'api/v1/guard/residences/$residenceUuid/attendance/start';

  static String attendanceEnd(String residenceUuid) =>
      'api/v1/guard/residences/$residenceUuid/attendance/end';

  static String attendanceList(String residenceUuid) =>
      'api/v1/guard/residences/$residenceUuid/attendance';

  static String visitors(String residenceUuid) =>
      'api/v1/guard/residences/$residenceUuid/visitors';

  static String visitorDetail(String residenceUuid, int visitorId) =>
      'api/v1/guard/residences/$residenceUuid/visitors/$visitorId';

  static String registerVisitor(String scopeUuid) =>
      'api/v1/guard/residences/$scopeUuid/visitors';

  static String visitorTypes(String scopeUuid) =>
      'api/v1/guard/residences/$scopeUuid/visitor-types';

  static String visitorScan(String residenceUuid) =>
      'api/v1/guard/residences/$residenceUuid/visitors/scan';

  static String visitorCheckIn(String residenceUuid, int visitorId) =>
      'api/v1/guard/residences/$residenceUuid/visitors/$visitorId/check-in';

  static String visitorCheckOut(String residenceUuid, int visitorId) =>
      'api/v1/guard/residences/$residenceUuid/visitors/$visitorId/check-out';

  static String unitBlocks(String residenceUuid) =>
      'api/v1/guard/residences/$residenceUuid/units/blocks';

  static String unitFloors(String residenceUuid) =>
      'api/v1/guard/residences/$residenceUuid/units/floors';

  static String unitList(String residenceUuid) =>
      'api/v1/guard/residences/$residenceUuid/units';

  static String unitHosts(String residenceUuid, String unitUuid) =>
      'api/v1/guard/residences/$residenceUuid/units/$unitUuid/hosts';

  static String incidentTypes(String residenceUuid) =>
      'api/v1/guard/residences/$residenceUuid/incidents/types';

  static String incidents(String residenceUuid) =>
      'api/v1/guard/residences/$residenceUuid/incidents';

  static String bookings(String residenceUuid) =>
      'api/v1/guard/residences/$residenceUuid/bookings';

  static String bookingDetail(String residenceUuid, int bookingId) =>
      'api/v1/guard/residences/$residenceUuid/bookings/$bookingId';

  static String bookingCheckIn(String residenceUuid, int bookingId) =>
      'api/v1/guard/residences/$residenceUuid/bookings/$bookingId/check-in';

  static String bookingCheckOut(String residenceUuid, int bookingId) =>
      'api/v1/guard/residences/$residenceUuid/bookings/$bookingId/check-out';
}
