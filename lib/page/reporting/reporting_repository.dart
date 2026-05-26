import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/guard_api_message.dart';
import '../../core/guard_api_paths.dart';
import '../../service/api_service.dart';
import 'reporting_models.dart';
import 'reporting_parsers.dart';

final reportingRepositoryProvider = Provider<ReportingRepository>(
  (ref) => ReportingRepository(ref.watch(dioProvider)),
);

class ReportingRepository {
  ReportingRepository(this._dio);

  final Dio _dio;

  /// `GET api/v1/guard/residences/{uuid}/incidents/types`
  Future<List<ReportingCategory>> fetchIncidentTypes(String residenceUuid) async {
    final res = await _dio.get<Map<String, dynamic>>(
      GuardApiPaths.incidentTypes(residenceUuid),
    );
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? 'Failed to load incident types',
      );
    }
    return parseIncidentTypesFromApi(body);
  }

  /// `POST api/v1/guard/residences/{uuid}/incidents` (multipart).
  Future<void> createIncident({
    required String residenceUuid,
    required String incidentType,
    required String description,
    required String incidentAt,
    required List<String> photoPaths,
  }) async {
    final form = FormData();
    form.fields.add(MapEntry('incident_type', incidentType));
    form.fields.add(MapEntry('description', description));
    form.fields.add(MapEntry('incident_at', incidentAt));
    for (var i = 0; i < photoPaths.length; i++) {
      form.files.add(
        MapEntry(
          'photos[]',
          await MultipartFile.fromFile(
            photoPaths[i],
            filename: 'incident_$i.jpg',
          ),
        ),
      );
    }
    final res = await _dio.post<Map<String, dynamic>>(
      GuardApiPaths.incidents(residenceUuid),
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? 'Incident report failed',
      );
    }
  }
}
