import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../service/api_service.dart';
import '../unit_call/unit_call_parser.dart';
import '../unit_call/unit_call_repository.dart';
import 'register_models.dart';
import 'register_parsers.dart';

final registerRepositoryProvider = Provider<RegisterRepository>(
  (ref) => RegisterRepository(ref.watch(dioProvider), ref.watch(unitCallRepositoryProvider)),
);

class RegisterRepository {
  RegisterRepository(this._dio, this._units);

  final Dio _dio;
  final UnitCallRepository _units;

  Future<List<RegisterUnitOption>> fetchUnitsForResidence(String residenceUuid) async {
    final raw = await _units.fetchAllResidenceUnits(residenceUuid);
    final rows = parseResidenceUnitResources(raw);
    return rows
        .map(
          (r) => RegisterUnitOption(
            unitUuid: r.id,
            unitName: r.name,
            blockName: r.block,
          ),
        )
        .toList();
  }

  Future<List<RegisterHostOption>> fetchUnitMembers(String unitUuid) async {
    final res = await _dio.get<dynamic>(
      'data-revise/residence_unit_memberships/members',
      queryParameters: <String, dynamic>{'unitUuid': unitUuid},
    );
    return parseUnitMembersResponse(res.data);
  }

  /// Android `RetrofitInterface.register_visitor` — `POST data/visitors`.
  Future<Map<String, dynamic>?> registerVisitor(Map<String, dynamic> body) async {
    final res = await _dio.post<dynamic>('data/visitors', data: body);
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
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
