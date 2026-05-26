import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api/client/dio_guard_http_client.dart';
import '../../core/api/client/guard_http_client.dart';
import '../../core/api/contracts/legacy_guard_data_repository.dart';

final homeRepositoryProvider = Provider<LegacyGuardDataRepository>(
  (ref) => HomeRepository(ref.watch(guardHttpClientProvider)),
);

/// Android `RetrofitListAPI`: guard PIN list (`data/kg_guards`).
final class HomeRepository implements LegacyGuardDataRepository {
  HomeRepository(this._client);

  final GuardHttpClient _client;

  static const _guardRelated =
      'kg_residence_guards_by_guard_uuid,kg_security_companies_by_security_company_uuid,'
      'residences_by_kg_residence_guards,residences_by_kg_attendances,kg_attendances_by_guard_uuid';

  @override
  Future<String> fetchGuardPinJson(String securityCompanyUuid) async {
    final filter = '((security_company_uuid=$securityCompanyUuid))';
    final data = await _client.getRaw(
      'data/kg_guards',
      query: <String, dynamic>{
        'filter': filter,
        'related': _guardRelated,
      },
    );
    if (data == null) return '{"resource":[]}';
    return jsonEncode(data);
  }

  @override
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
