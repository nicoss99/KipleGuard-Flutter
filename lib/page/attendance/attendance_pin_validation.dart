import 'dart:convert';

import '../../core/guard_pin_bypass.dart';

/// Android `AttendanceActivity.checkGuardPin`: match PIN and residence on `kg_residence_guards_by_guard_uuid`.
({String guardUuid, String companyUuid})? matchGuardForResidence({
  required String securityJson,
  required String residenceUuid,
  required String pin6,
  String fallbackCompanyUuid = '',
}) {
  if (residenceUuid.trim().isEmpty || pin6.length != 6) return null;
  if (GuardPinBypass.matches(pin6)) {
    return GuardPinBypass.matchForResidence(
      securityJson: securityJson,
      residenceUuid: residenceUuid,
      fallbackCompanyUuid: fallbackCompanyUuid,
    );
  }
  if (securityJson.trim().isEmpty) return null;
  try {
    final decoded = jsonDecode(securityJson);
    if (decoded is! Map<String, dynamic>) return null;
    final res = decoded['resource'];
    if (res is! List<dynamic>) return null;
    for (final e in res) {
      if (e is! Map<String, dynamic>) continue;
      final storedPin = e['pin']?.toString() ?? '';
      if (storedPin != pin6) continue;
      final guardUuid = e['uuid']?.toString() ?? '';
      final companyUuid = e['security_company_uuid']?.toString() ?? '';
      if (guardUuid.isEmpty) continue;
      final links = e['kg_residence_guards_by_guard_uuid'];
      if (links is! List<dynamic>) continue;
      for (final link in links) {
        if (link is! Map<String, dynamic>) continue;
        final rid = link['residence_uuid']?.toString() ?? '';
        if (rid.toLowerCase() == residenceUuid.toLowerCase()) {
          return (guardUuid: guardUuid, companyUuid: companyUuid);
        }
      }
    }
  } catch (_) {}
  return null;
}
