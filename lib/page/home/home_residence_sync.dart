import 'dart:convert';

import '../../core/dashboard_prefs.dart';
import 'residence_cover_url.dart';

List<Map<String, dynamic>> parseRolesList(String? rolesJson) {
  if (rolesJson == null || rolesJson.isEmpty) return [];
  final decoded = jsonDecode(rolesJson);
  if (decoded is! List<dynamic>) return [];
  final out = <Map<String, dynamic>>[];
  for (final e in decoded) {
    if (e is Map<String, dynamic>) {
      out.add(e);
    } else if (e is String) {
      try {
        final m = jsonDecode(e);
        if (m is Map<String, dynamic>) out.add(m);
      } catch (_) {}
    }
  }
  return out;
}

/// Mirrors `DashboardActivity.residenceAPI` mapping + `DBOthers` writes (Flutter has no `DBResidences` yet).
Future<void> syncResidencesFromResponse({
  required Map<String, dynamic> body,
  required String rolesJson,
  required bool alreadyHadResidenceName,
  required String currentResidenceId,
}) async {
  final resources = body['resource'];
  if (resources is! List<dynamic>) {
    return;
  }

  final roles = parseRolesList(rolesJson);

  for (final raw in resources) {
    if (raw is! Map<String, dynamic>) continue;
    final resource = Map<String, dynamic>.from(raw);

    var kipleguardEnabled = resource['kipleguard_enabled'] as bool?;
    var kipleguardAttendance = resource['kipleguard_attendance'] as bool?;
    var kipleguardReporting = resource['kipleguard_reporting'] as bool?;
    var kipleguardVisitors = resource['kipleguard_visitors'] as bool?;
    var qrcodeEnabled = resource['qrcode_enabled'] as bool?;

    kipleguardAttendance ??= true;
    kipleguardReporting ??= true;
    kipleguardVisitors ??= true;
    kipleguardEnabled ??= false;
    qrcodeEnabled ??= false;

    if (kipleguardEnabled != true) continue;

    final uuid = resource['uuid'] as String?;
    if (uuid == null) continue;

    final name = resource['name'] as String? ?? '';
    final guardLocalDir = resource['guard_local_directory_feature_enabled'] == true;
    final callOption = resource['call_option'] as String? ?? '';
    final securityCompanyUuid = resource['security_company_uuid'] as String? ?? '';
    final facilityEnabled = resource['facility_feature_enabled'] as bool?;
    final hdfEnabled = resource['hdf_enabled'] as bool?;
    final healthCodeEnabled = resource['health_code_enabled'] as bool?;
    final quarantineDays = resource['quarantine_days'];
    final normalTemperature = resource['normal_temperature'];
    final lprEnabled = resource['lpr_enabled'] as bool?;
    final parkingEnabled = resource['parking_feature_enabled'] as bool?;
    final residenceType = resource['type']?.toString() ?? '';

    final coverUrl = extractResidenceCoverUrl(resource);

    final buildingArr = <Map<String, dynamic>>[];
    final br = resource['building_residences_by_building_uuid'];
    if (br is List<dynamic>) {
      for (final b in br) {
        if (b is Map<String, dynamic>) {
          buildingArr.add(<String, dynamic>{
            'uuid': b['uuid'],
            'company_uuid': b['company_uuid'],
            'name': b['name'],
          });
        }
      }
    }
    final buildingJson = jsonEncode(buildingArr);

    for (final role in roles) {
      final type = role['type']?.toString();
      final residenceUuid = role['residence_uuid']?.toString();
      if (type == null || residenceUuid == null) continue;
      if (type == 'admin') continue;
      if (residenceUuid != uuid) continue;

      var localIntercom = 'false';
      var attendance = 'false';
      var visitors = 'false';
      var reporting = 'false';
      var booking = 'false';
      var qrcode = 'false';
      var hdf = 'false';
      var healthcode = 'false';
      var quarantineDaysStr = '0';
      var normalTempStr = '37.5';
      var lprStr = 'false';
      const frEnableStr = 'false';

      if (guardLocalDir) localIntercom = 'true';
      if (kipleguardAttendance) attendance = 'true';
      if (kipleguardVisitors) visitors = 'true';
      if (kipleguardReporting) reporting = 'true';
      if (qrcodeEnabled) qrcode = 'true';
      if (facilityEnabled == true) booking = 'true';
      if (hdfEnabled == true) hdf = 'true';
      if (healthCodeEnabled == true) healthcode = 'true';
      if (quarantineDays != null) quarantineDaysStr = quarantineDays.toString();
      if (normalTemperature != null) normalTempStr = normalTemperature.toString();
      if (lprEnabled == true || parkingEnabled == true) lprStr = 'true';

      if (!alreadyHadResidenceName || currentResidenceId == uuid) {
        await DashboardPrefs.writeResidenceSelection(
          residenceUuid: uuid,
          residenceName: name,
          coverUrl: coverUrl,
          callOption: callOption,
          intercomEnabled: localIntercom,
          attendance: attendance,
          visitors: visitors,
          reporting: reporting,
          booking: booking,
          securityCompanyUuid: securityCompanyUuid,
          qr: qrcode,
          officeType: residenceType,
          frEnable: frEnableStr,
          buildingResidencesJson: buildingJson,
          hdf: hdf,
          healthCode: healthcode,
          quarantineDays: quarantineDaysStr,
          normalTemp: normalTempStr,
          lpr: lprStr,
        );
      }
    }
  }
}
