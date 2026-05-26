import '../../core/auth_prefs.dart';
import '../auth/guard_models.dart';
import 'residence_choice.dart';

/// Maps guard login/me residences into [ResidenceChoice] for site picker.
List<ResidenceChoice> guardResidencesToChoices(List<GuardResidence> list) {
  return list
      .map(
        (r) => ResidenceChoice(
          uuid: r.uuid,
          name: r.name,
          coverUrl: r.imageUrl?.trim() ?? '',
          callOption: '',
          intercom: 'true',
          attendance: 'true',
          visitors: 'true',
          reporting: 'true',
          booking: 'true',
          securityUuid: r.securityCompanyUuid?.trim() ?? '',
          qr: 'true',
          officeType: 'residence',
          frEnable: 'false',
          buildingResidencesJson: '[]',
          hdf: 'false',
          healthCode: 'false',
          quarantineDays: '0',
          normalTemp: '37.5',
          lpr: 'false',
        ),
      )
      .toList();
}

Future<List<ResidenceChoice>> loadGuardResidenceChoices() async {
  final list = await AuthPrefs.readGuardResidences();
  return guardResidencesToChoices(list);
}
