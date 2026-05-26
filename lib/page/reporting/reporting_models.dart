/// Incident type from `GET .../incidents/types` (`key` + `label`).
class ReportingCategory {
  const ReportingCategory({required this.key, required this.label});

  final String key;
  final String label;
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
