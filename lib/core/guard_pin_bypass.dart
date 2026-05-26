import 'dart:convert';

/// Temporary dev bypass — remove when guard PIN list is reliable in all environments.
abstract final class GuardPinBypass {
  static const pin = '123456';

  static bool matches(String pin6) => pin6.trim() == pin;

  /// First guard linked to [residenceUuid], else placeholders for open-shift checks.
  static ({String guardUuid, String companyUuid}) matchForResidence({
    required String securityJson,
    required String residenceUuid,
    String fallbackCompanyUuid = '',
  }) {
    final fromJson = _firstGuardForResidence(securityJson, residenceUuid);
    if (fromJson != null) return fromJson;
    return (
      guardUuid: '',
      companyUuid: fallbackCompanyUuid.trim(),
    );
  }
}

({String guardUuid, String companyUuid})? _firstGuardForResidence(
  String securityJson,
  String residenceUuid,
) {
  if (securityJson.trim().isEmpty || residenceUuid.trim().isEmpty) return null;
  try {
    final decoded = jsonDecode(securityJson);
    if (decoded is! Map<String, dynamic>) return null;
    final res = decoded['resource'];
    if (res is! List<dynamic>) return null;
    for (final e in res) {
      if (e is! Map<String, dynamic>) continue;
      final guardUuid = e['uuid']?.toString() ?? '';
      if (guardUuid.isEmpty) continue;
      final companyUuid = e['security_company_uuid']?.toString() ?? '';
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
    final first = res.firstWhere(
      (e) => e is Map<String, dynamic> && (e['uuid']?.toString() ?? '').isNotEmpty,
      orElse: () => null,
    );
    if (first is Map<String, dynamic>) {
      return (
        guardUuid: first['uuid']?.toString() ?? '',
        companyUuid: first['security_company_uuid']?.toString() ?? '',
      );
    }
  } catch (_) {}
  return null;
}
