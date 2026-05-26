import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api/client/dio_guard_http_client.dart';
import '../../core/api/client/guard_http_client.dart';
import '../../core/api/contracts/guard_reporting_repository.dart';
import '../../core/api/messages/api_message_catalog.dart';
import '../../core/api/messages/localized_api_message_catalog.dart';
import '../../core/guard_api_paths.dart';
import 'reporting_models.dart';
import 'reporting_parsers.dart';

final reportingRepositoryProvider = Provider<GuardReportingRepository>(
  (ref) => ReportingRepository(
    ref.watch(guardHttpClientProvider),
    ref.watch(apiMessageCatalogProvider),
  ),
);

final class ReportingRepository implements GuardReportingRepository {
  ReportingRepository(this._client, this._messages);

  final GuardHttpClient _client;
  final ApiMessageCatalog _messages;

  @override
  Future<List<ReportingCategory>> fetchIncidentTypes(String residenceUuid) async {
    final data = await _client.getJson(
      GuardApiPaths.incidentTypes(residenceUuid),
      fallbackMessage: _messages.incidentTypesLoadFailed,
    );
    return parseIncidentTypesFromApi(<String, dynamic>{'success': true, 'data': data});
  }

  @override
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
    await _client.postMultipart(
      GuardApiPaths.incidents(residenceUuid),
      data: form,
      fallbackMessage: _messages.incidentReportFailed,
    );
  }
}
