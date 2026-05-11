import 'dart:convert';

/// Android `ReportingStep1Activity.checkGuardPin` — local verify against `securityJson`.
class ReportingPinResult {
  const ReportingPinResult.success({
    required this.guardPin,
    required this.guardUuid,
    required this.companyUuid,
  }) : ok = true;

  const ReportingPinResult.failure() : ok = false, guardPin = '', guardUuid = '', companyUuid = '';

  final bool ok;
  final String guardPin;
  final String guardUuid;
  final String companyUuid;
}

ReportingPinResult verifyGuardPin({
  required String securityJson,
  required String residenceUuid,
  required String pin,
}) {
  if (securityJson.isEmpty || pin.length != 6) return const ReportingPinResult.failure();
  try {
    final decoded = jsonDecode(securityJson);
    if (decoded is! Map<String, dynamic>) return const ReportingPinResult.failure();
    final resource = decoded['resource'];
    if (resource is! List<dynamic>) return const ReportingPinResult.failure();
    for (final item in resource) {
      if (item is! Map<String, dynamic>) continue;
      final guardPin = item['pin']?.toString() ?? '';
      final guardUuid = item['uuid']?.toString() ?? '';
      final companyUuid = item['security_company_uuid']?.toString() ?? '';
      final links = item['kg_residence_guards_by_guard_uuid'];
      if (links is! List<dynamic>) continue;
      for (final link in links) {
        if (link is! Map<String, dynamic>) continue;
        final rid = link['residence_uuid']?.toString();
        if (rid == residenceUuid && pin == guardPin) {
          return ReportingPinResult.success(
            guardPin: guardPin,
            guardUuid: guardUuid,
            companyUuid: companyUuid,
          );
        }
      }
    }
  } catch (_) {
    return const ReportingPinResult.failure();
  }
  return const ReportingPinResult.failure();
}
