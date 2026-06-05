import '../../core/guard_api_message.dart';

/// Guard identity optionally returned by `verify-pin` `data`.
class GuardPinVerifyIdentity {
  const GuardPinVerifyIdentity({
    required this.guardUuid,
    this.companyUuid = '',
  });

  final String guardUuid;
  final String companyUuid;
}

GuardPinVerifyIdentity? parseGuardIdentityFromVerifyPinData(
  Map<String, dynamic>? data,
) {
  if (data == null) return null;

  final guard = asStringKeyedMap(data['guard']);
  final guardUuid = data['guard_uuid']?.toString().trim() ??
      data['kg_guard_uuid']?.toString().trim() ??
      data['uuid']?.toString().trim() ??
      guard?['uuid']?.toString().trim() ??
      guard?['guard_uuid']?.toString().trim() ??
      '';
  if (guardUuid.isEmpty) return null;

  final companyUuid = data['security_company_uuid']?.toString().trim() ??
      data['company_uuid']?.toString().trim() ??
      guard?['security_company_uuid']?.toString().trim() ??
      '';
  return GuardPinVerifyIdentity(
    guardUuid: guardUuid,
    companyUuid: companyUuid,
  );
}
