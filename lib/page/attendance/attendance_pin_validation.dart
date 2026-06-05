import 'dart:convert';

import '../auth/guard_pin_verify_identity.dart';

/// Resolves guard identity from cached security JSON after API PIN verification.
({String guardUuid, String companyUuid})? matchGuardForResidence({
  required String securityJson,
  required String residenceUuid,
  required String pin6,
  String fallbackCompanyUuid = '',
}) {
  if (residenceUuid.trim().isEmpty || pin6.length != 6) return null;
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
      final match = _guardLinkedToResidence(e, residenceUuid);
      if (match != null) return match;
    }
  } catch (_) {}
  return null;
}

/// First guard linked to [residenceUuid] when API already verified the PIN.
({String guardUuid, String companyUuid})? firstGuardForResidence({
  required String securityJson,
  required String residenceUuid,
  String fallbackCompanyUuid = '',
}) {
  if (residenceUuid.trim().isEmpty || securityJson.trim().isEmpty) return null;
  try {
    final decoded = jsonDecode(securityJson);
    if (decoded is! Map<String, dynamic>) return null;
    final res = decoded['resource'];
    if (res is! List<dynamic>) return null;
    for (final e in res) {
      if (e is! Map<String, dynamic>) continue;
      final match = _guardLinkedToResidence(e, residenceUuid);
      if (match != null) return match;
    }
  } catch (_) {}
  return null;
}

/// After [verify-pin] succeeds, local cache is optional — never treat as invalid PIN.
({String guardUuid, String companyUuid}) resolveGuardAfterApiPin({
  required String securityJson,
  required String residenceUuid,
  required String pin6,
  String fallbackCompanyUuid = '',
  GuardPinVerifyIdentity? apiIdentity,
}) {
  final local = matchGuardForResidence(
    securityJson: securityJson,
    residenceUuid: residenceUuid,
    pin6: pin6,
    fallbackCompanyUuid: fallbackCompanyUuid,
  );
  if (local != null) return local;

  final apiGuard = apiIdentity?.guardUuid.trim() ?? '';
  if (apiGuard.isNotEmpty) {
    return (
      guardUuid: apiGuard,
      companyUuid: _resolvedCompanyUuid(apiIdentity, fallbackCompanyUuid),
    );
  }

  final first = firstGuardForResidence(
    securityJson: securityJson,
    residenceUuid: residenceUuid,
    fallbackCompanyUuid: fallbackCompanyUuid,
  );
  if (first != null) return first;

  return (guardUuid: '', companyUuid: fallbackCompanyUuid.trim());
}

String _resolvedCompanyUuid(
  GuardPinVerifyIdentity? apiIdentity,
  String fallbackCompanyUuid,
) {
  final fromApi = apiIdentity?.companyUuid.trim() ?? '';
  if (fromApi.isNotEmpty) return fromApi;
  return fallbackCompanyUuid.trim();
}

({String guardUuid, String companyUuid})? _guardLinkedToResidence(
  Map<String, dynamic> guard,
  String residenceUuid,
) {
  final guardUuid = guard['uuid']?.toString() ?? '';
  final companyUuid = guard['security_company_uuid']?.toString() ?? '';
  if (guardUuid.isEmpty) return null;
  final links = guard['kg_residence_guards_by_guard_uuid'];
  if (links is! List<dynamic>) return null;
  for (final link in links) {
    if (link is! Map<String, dynamic>) continue;
    final rid = link['residence_uuid']?.toString() ?? '';
    if (rid.toLowerCase() == residenceUuid.toLowerCase()) {
      return (guardUuid: guardUuid, companyUuid: companyUuid);
    }
  }
  return null;
}
