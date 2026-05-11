import 'package:shared_preferences/shared_preferences.dart';

import 'unit_call_session_prefs.dart';

/// Mirrors Android `DBOthers` keys written from [DashboardActivity] / residence sync.
abstract final class DashboardPrefs {
  static const userResidenceIdKey = 'userResidenceID';
  static const userResidenceKey = 'userResidence';
  static const userResidenceImageKey = 'userResidenceImage';
  static const userResidenceCallKey = 'userResidenceCall';
  static const userResidenceIntercomKey = 'userResidenceIntercom';
  static const attendanceEnableKey = 'attendanceEnable';
  static const visitorEnableKey = 'visitorEnable';
  static const reportEnableKey = 'reportEnable';
  static const bookingEnableKey = 'bookingEnable';
  static const securityUuidKey = 'securityUUID';
  static const qrEnableKey = 'qrEnable';
  static const officeEnableKey = 'officeEnable';
  static const frEnableKey = 'frEnable';
  static const buildingResidencesKey = 'buildingResidences';
  static const hdfEnabledKey = 'hdfEnabled';
  static const healthCodeEnabledKey = 'healthCodeEnabled';
  static const quarantineDaysKey = 'quarantineDays';
  static const normalTempKey = 'normalTemp';
  static const lprEnabledKey = 'lprEnabled';
  static const securityJsonKey = 'securityJson';
  static const visitorTypesJsonKey = 'visitorTypesListJson';

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final extraKeys = prefs.getKeys().where((k) => k.startsWith('kiple_call_history_'));
    for (final k in extraKeys) {
      await prefs.remove(k);
    }

    for (final k in [
      userResidenceIdKey,
      userResidenceKey,
      userResidenceImageKey,
      userResidenceCallKey,
      userResidenceIntercomKey,
      attendanceEnableKey,
      visitorEnableKey,
      reportEnableKey,
      bookingEnableKey,
      securityUuidKey,
      qrEnableKey,
      officeEnableKey,
      frEnableKey,
      buildingResidencesKey,
      hdfEnabledKey,
      healthCodeEnabledKey,
      quarantineDaysKey,
      normalTempKey,
      lprEnabledKey,
      securityJsonKey,
      visitorTypesJsonKey,
    ]) {
      await prefs.remove(k);
    }
    await UnitCallSessionPrefs.clear();
  }

  static Future<void> writeResidenceSelection({
    required String residenceUuid,
    required String residenceName,
    required String coverUrl,
    required String callOption,
    required String intercomEnabled,
    required String attendance,
    required String visitors,
    required String reporting,
    required String booking,
    required String securityCompanyUuid,
    required String qr,
    required String officeType,
    required String frEnable,
    required String buildingResidencesJson,
    required String hdf,
    required String healthCode,
    required String quarantineDays,
    required String normalTemp,
    required String lpr,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    Future<void> put(String k, String v) async {
      await prefs.remove(k);
      await prefs.setString(k, v);
    }

    await put(userResidenceIdKey, residenceUuid);
    await put(userResidenceKey, residenceName);
    await put(userResidenceImageKey, coverUrl);
    await put(userResidenceCallKey, callOption);
    await put(userResidenceIntercomKey, intercomEnabled);
    await put(attendanceEnableKey, attendance);
    await put(visitorEnableKey, visitors);
    await put(reportEnableKey, reporting);
    await put(bookingEnableKey, booking);
    await put(securityUuidKey, securityCompanyUuid);
    await put(qrEnableKey, qr);
    await put(officeEnableKey, officeType);
    await put(frEnableKey, frEnable);
    await put(buildingResidencesKey, buildingResidencesJson);
    await put(hdfEnabledKey, hdf);
    await put(healthCodeEnabledKey, healthCode);
    await put(quarantineDaysKey, quarantineDays);
    await put(normalTempKey, normalTemp);
    await put(lprEnabledKey, lpr);
  }

  static Future<void> setSecurityJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(securityJsonKey, json);
  }

  static Future<void> setVisitorTypesJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(visitorTypesJsonKey, json);
  }

  static Future<DashboardSnapshot> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    String g(String k) => prefs.getString(k) ?? '';

    return DashboardSnapshot(
      residenceName: g(userResidenceKey),
      residenceId: g(userResidenceIdKey),
      attendance: g(attendanceEnableKey) == 'true',
      visitor: g(visitorEnableKey) == 'true',
      report: g(reportEnableKey) == 'true',
      booking: g(bookingEnableKey) == 'true',
      intercom: g(userResidenceIntercomKey) == 'true',
      qr: g(qrEnableKey) == 'true',
      lprEnabled: g(lprEnabledKey) == 'true',
      securityUuid: g(securityUuidKey),
      officeEnable: g(officeEnableKey),
      callOption: g(userResidenceCallKey),
      buildingResidencesJson: g(buildingResidencesKey),
    );
  }

  /// Mirrors Android `UnitActivity` / `DBOthers.officeEnable` checks.
  static bool isOfficeEnvironment(String officeEnable) {
    if (officeEnable.isEmpty) return false;
    final l = officeEnable.toLowerCase();
    var officeEnvironment = false;
    if (l.contains('residence')) officeEnvironment = false;
    if (l.contains('office')) officeEnvironment = true;
    if (l.contains('building')) officeEnvironment = true;
    if (l.contains('mall')) officeEnvironment = true;
    if (l.contains('public spaces')) officeEnvironment = true;
    if (l.contains('school')) officeEnvironment = true;
    if (l.contains('exhibition')) officeEnvironment = true;
    return officeEnvironment;
  }
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.residenceName,
    required this.residenceId,
    required this.attendance,
    required this.visitor,
    required this.report,
    required this.booking,
    required this.intercom,
    required this.qr,
    required this.lprEnabled,
    required this.securityUuid,
    this.officeEnable = '',
    this.callOption = '',
    this.buildingResidencesJson = '',
  });

  final String residenceName;
  final String residenceId;
  final bool attendance;
  final bool visitor;
  final bool report;
  final bool booking;
  final bool intercom;
  final bool qr;
  final bool lprEnabled;
  final String securityUuid;
  final String officeEnable;
  final String callOption;
  final String buildingResidencesJson;

  bool get hasResidence => residenceName.isNotEmpty;

  bool get isStrictBuildingOffice => officeEnable.trim().toLowerCase() == 'building';

  bool get officeEnvironment => DashboardPrefs.isOfficeEnvironment(officeEnable);
}
