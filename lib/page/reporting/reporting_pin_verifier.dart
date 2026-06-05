/// Guard identity resolved after API PIN verification (reporting flow).
class ReportingPinResult {
  const ReportingPinResult.success({
    required this.guardPin,
    required this.guardUuid,
    required this.companyUuid,
  }) : ok = true;

  const ReportingPinResult.failure()
      : ok = false,
        guardPin = '',
        guardUuid = '',
        companyUuid = '';

  final bool ok;
  final String guardPin;
  final String guardUuid;
  final String companyUuid;
}
