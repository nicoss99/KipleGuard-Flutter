import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../service/api_service.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepository(ref.watch(dioProvider)),
);

/// Android `RetrofitListAPI`: residences, guard_pin, types (TypeList2).
class HomeRepository {
  HomeRepository(this._dio);

  final Dio _dio;

  /// Same comma-separated value as Android `RetrofitListAPI` / K8s `related` query.
  static const residencesRelated =
      'files_by_cover_photo,building_residences_by_building_uuid';

  static const _guardRelated =
      'kg_residence_guards_by_guard_uuid,kg_security_companies_by_security_company_uuid,'
      'residences_by_kg_residence_guards,residences_by_kg_attendances,kg_attendances_by_guard_uuid';

  /// Residence list + embedded cover file (`files_by_cover_photo`).
  ///
  /// With [AppConfig.baseUrl] `https://k8s-api.kiplelive.com/` (prod K8s), Dio resolves to:
  /// `https://k8s-api.kiplelive.com/data/residences?related=files_by_cover_photo%2Cbuilding_residences_by_building_uuid`.
  /// Cover image URLs are taken from that JSON (`files_by_cover_photo.url` / `preview`, etc.), not a second API.
  Future<Map<String, dynamic>> fetchResidences() async {
    final res = await _dio.get<dynamic>(
      'data/residences',
      queryParameters: <String, dynamic>{'related': residencesRelated},
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    throw StateError('Invalid residences payload');
  }

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

  Future<String> fetchVisitorTypesJson(String residenceUuid) async {
    final filter = '((residence_uuid=$residenceUuid) AND (deleted_at is null))';
    final res = await _dio.get<dynamic>(
      'data/visitor_types',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'order': 'name ASC',
        'related': '',
        'include_count': 'true',
        'offset': '0',
        'limit': '10000',
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
