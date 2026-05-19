import '../../core/dashboard_prefs.dart';

/// One selectable row matching Android `ResidenceObject` / `DBResidences` + prefs write.
class ResidenceChoice {
  const ResidenceChoice({
    required this.uuid,
    required this.name,
    required this.coverUrl,
    required this.callOption,
    required this.intercom,
    required this.attendance,
    required this.visitors,
    required this.reporting,
    required this.booking,
    required this.securityUuid,
    required this.qr,
    required this.officeType,
    required this.frEnable,
    required this.buildingResidencesJson,
    required this.hdf,
    required this.healthCode,
    required this.quarantineDays,
    required this.normalTemp,
    required this.lpr,
  });

  final String uuid;
  final String name;
  final String coverUrl;
  final String callOption;
  final String intercom;
  final String attendance;
  final String visitors;
  final String reporting;
  final String booking;
  final String securityUuid;
  final String qr;
  final String officeType;
  final String frEnable;
  final String buildingResidencesJson;
  final String hdf;
  final String healthCode;
  final String quarantineDays;
  final String normalTemp;
  final String lpr;

  bool get hasCover {
    final u = coverUrl.trim();
    if (u.isEmpty) return false;
    final lower = u.toLowerCase();
    if (lower == 'null' || lower == 'undefined') return false;
    return true;
  }

  Future<void> persist() => DashboardPrefs.writeResidenceSelection(
        residenceUuid: uuid,
        residenceName: name,
        coverUrl: coverUrl,
        callOption: callOption,
        intercomEnabled: intercom,
        attendance: attendance,
        visitors: visitors,
        reporting: reporting,
        booking: booking,
        securityCompanyUuid: securityUuid,
        qr: qr,
        officeType: officeType,
        frEnable: frEnable,
        buildingResidencesJson: buildingResidencesJson,
        hdf: hdf,
        healthCode: healthCode,
        quarantineDays: quarantineDays,
        normalTemp: normalTemp,
        lpr: lpr,
      );
}
