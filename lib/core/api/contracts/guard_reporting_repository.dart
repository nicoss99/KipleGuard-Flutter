import '../../../page/reporting/reporting_models.dart';

/// Guard incident reporting API.
abstract interface class GuardReportingRepository {
  Future<List<ReportingCategory>> fetchIncidentTypes(String residenceUuid);

  Future<void> createIncident({
    required String residenceUuid,
    required String pin,
    required String incidentType,
    required String description,
    required String incidentAt,
    required List<String> photoPaths,
  });
}
