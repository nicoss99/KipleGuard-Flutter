import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/guard_api_message.dart';
import '../../core/guard_api_paths.dart';
import '../../service/api_service.dart';
import '../unit_call/guard_unit_call_repository.dart';
import 'register_models.dart';
import 'register_parsers.dart';

final registerRepositoryProvider = Provider<RegisterRepository>(
  (ref) => RegisterRepository(
    ref.watch(dioProvider),
    ref.watch(guardUnitCallRepositoryProvider),
  ),
);

class RegisterRepository {
  RegisterRepository(this._dio, this._guardUnits);

  final Dio _dio;
  final GuardUnitCallRepository _guardUnits;

  /// Same unit directory as [UnitCallPage] (Guard blocks/floors/units or office list).
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

  /// `GET api/v1/guard/residences/{uuid}/units/{unitUuid}/hosts`
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

  /// Guard API `GET /api/v1/guard/residences/{scopeUuid}/visitor-types`.
  Future<List<RegisterVisitorTypeOption>> fetchVisitorTypes(String scopeUuid) async {
    final res = await _dio.get<Map<String, dynamic>>(
      GuardApiPaths.visitorTypes(scopeUuid),
    );
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? 'Failed to load visitor types',
      );
    }
    return parseVisitorTypeOptionsFromApi(body);
  }

  /// Guard API `POST /api/v1/guard/residences/{scopeUuid}/visitors` (multipart).
  Future<Map<String, dynamic>?> registerVisitor({
    required String scopeUuid,
    required FormData body,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      GuardApiPaths.registerVisitor(scopeUuid),
      data: body,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = res.data;
    if (data == null) return null;
    if (!guardApiSuccess(data)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: data['message'] as String? ?? 'Visitor registration failed',
      );
    }
    return data;
  }

  /// Android `add_visitor_access_card` after QR register.
  Future<void> addVisitorAccessCard({
    required String visitorUuid,
    required String visitorTypeUuid,
    required String residenceUuid,
    required String unitUuid,
  }) async {
    await _dio.post<dynamic>(
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
