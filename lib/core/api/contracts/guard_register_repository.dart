import 'package:dio/dio.dart';

import '../../../page/register/register_models.dart';

/// Guard visitor registration API.
abstract interface class GuardRegisterRepository {
  Future<List<RegisterUnitOption>> fetchUnitsForResidence(
    String residenceUuid, {
    required bool officeMode,
  });

  Future<List<RegisterHostOption>> fetchHostsForUnit({
    required String residenceUuid,
    required String unitUuid,
  });

  Future<List<RegisterVisitorTypeOption>> fetchVisitorTypes(String scopeUuid);

  Future<Map<String, dynamic>?> registerVisitor({
    required String scopeUuid,
    required FormData body,
  });

  Future<void> addVisitorAccessCard({
    required String visitorUuid,
    required String visitorTypeUuid,
    required String residenceUuid,
    required String unitUuid,
  });
}
