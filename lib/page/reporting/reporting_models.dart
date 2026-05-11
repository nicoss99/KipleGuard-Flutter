/// Incident category from `data/kg_incident_categories` (`RetrofitPOJO.resource`).
class ReportingCategory {
  const ReportingCategory({required this.uuid, required this.name});

  final String uuid;
  final String name;
}

/// Passed to the reporting form after PIN verification (Android intent extras).
class ReportingFormArgs {
  const ReportingFormArgs({
    required this.guardPin,
    required this.guardUuid,
    required this.companyUuid,
  });

  final String guardPin;
  final String guardUuid;
  final String companyUuid;
}
