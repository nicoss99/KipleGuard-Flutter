import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api/client/dio_guard_http_client.dart';
import '../../core/api/client/guard_http_client.dart';
import '../../core/api/contracts/guard_register_repository.dart';
import '../../core/api/contracts/guard_unit_call_repository.dart';
import '../../core/api/messages/api_message_catalog.dart';
import '../../core/api/messages/localized_api_message_catalog.dart';
import '../../core/guard_api_paths.dart';
import '../unit_call/guard_unit_call_repository.dart';
import 'register_models.dart';
import 'register_parsers.dart';

final registerRepositoryProvider = Provider<GuardRegisterRepository>(
  (ref) => RegisterRepository(
    ref.watch(guardHttpClientProvider),
    ref.watch(guardUnitCallRepositoryProvider),
    ref.watch(apiMessageCatalogProvider),
  ),
);

final class RegisterRepository implements GuardRegisterRepository {
  RegisterRepository(this._client, this._guardUnits, this._messages);

  final GuardHttpClient _client;
  final GuardUnitCallRepository _guardUnits;
  final ApiMessageCatalog _messages;

  @override
  Future<List<RegisterUnitOption>> fetchUnitsForResidence(
    String residenceUuid, {
    required bool officeMode,
  }) async {
    final rows = await _guardUnits.fetchAllUnitsForResidence(
      residenceUuid,
      officeMode: officeMode,
    );
    return rows
        .map(
          (r) => RegisterUnitOption(
            unitUuid: r.id,
            unitName: r.name,
            blockName: r.block.trim().isEmpty ? 'N/A Block' : r.block,
          ),
        )
        .toList();
  }

  @override
  Future<List<RegisterHostOption>> fetchHostsForUnit({
    required String residenceUuid,
    required String unitUuid,
  }) async {
    final members = await _guardUnits.fetchHosts(
      residenceUuid,
      unitUuid: unitUuid,
    );
    return members
        .map(
          (m) => RegisterHostOption(
            uuid: m.membershipUuid,
            name: m.name,
            phone: m.phone,
            userId: m.userId ?? int.tryParse(m.membershipUuid),
          ),
        )
        .toList();
  }

  @override
  Future<List<RegisterVisitorTypeOption>> fetchVisitorTypes(String scopeUuid) async {
    final data = await _client.getJson(
      GuardApiPaths.visitorTypes(scopeUuid),
      fallbackMessage: _messages.visitorTypesLoadFailed,
    );
    return parseVisitorTypeOptionsFromApi(<String, dynamic>{'success': true, 'data': data});
  }

  @override
  Future<Map<String, dynamic>?> registerVisitor({
    required String scopeUuid,
    required FormData body,
  }) async {
    final data = await _client.postMultipart(
      GuardApiPaths.registerVisitor(scopeUuid),
      data: body,
      fallbackMessage: _messages.requestFailed,
    );
    if (data == null) return null;
    return <String, dynamic>{'success': true, 'data': data};
  }

  @override
  Future<void> addVisitorAccessCard({
    required String visitorUuid,
    required String visitorTypeUuid,
    required String residenceUuid,
    required String unitUuid,
  }) async {
    await _client.postJson(
      'accesscards/newvisitor',
      data: <String, dynamic>{
        'visitor_uuid': visitorUuid,
        'visitor_type_uuid': visitorTypeUuid,
        'unit_uuid': unitUuid,
        'residence_uuid': residenceUuid,
      },
    );
  }
}
