import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../service/api_service.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepository(ref.watch(dioProvider)),
);

/// Android `RetrofitListAPI`: guard PIN list (`data/kg_guards`).
class HomeRepository {
  HomeRepository(this._dio);

  final Dio _dio;

  static const _guardRelated =
      'kg_residence_guards_by_guard_uuid,kg_security_companies_by_security_company_uuid,'
      'residences_by_kg_residence_guards,residences_by_kg_attendances,kg_attendances_by_guard_uuid';

  Future<String> fetchGuardPinJson(String securityCompanyUuid) async {
    final filter = '((security_company_uuid=$securityCompanyUuid))';
    final res = await _dio.get<dynamic>(
      'data/kg_guards',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'related': _guardRelated,
      },
    );
    final data = res.data;
    if (data == null) return '{"resource":[]}';
    return jsonEncode(data);
  }

  /// Matches Android `guardPinAPI` trimmed JSON stored in `securityJson`.
  String trimGuardPinPayload(String responseString) {
    final decoded = jsonDecode(responseString);
    if (decoded is! Map<String, dynamic>) return responseString;
    final resource = decoded['resource'];
    if (resource is! List<dynamic>) return responseString;
    final list = <Map<String, dynamic>>[];
    for (final item in resource) {
      if (item is! Map<String, dynamic>) continue;
      list.add(<String, dynamic>{
        'pin': item['pin'],
        'uuid': item['uuid'],
        'security_company_uuid': item['security_company_uuid'],
        'kg_residence_guards_by_guard_uuid': item['kg_residence_guards_by_guard_uuid'],
      });
    }
    return jsonEncode(<String, dynamic>{'resource': list});
  }
}
