import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/dashboard_prefs.dart';
import '../home/home_repository.dart';
import 'register_models.dart';
import 'register_parsers.dart';
import 'register_repository.dart';

class RegisterVisitData {
  const RegisterVisitData({required this.types, required this.units});

  final List<RegisterVisitorTypeOption> types;
  final List<RegisterUnitOption> units;
}

Future<RegisterVisitData> loadRegisterVisitData(
  WidgetRef ref,
  String residenceUuid, {
  bool forceRefreshTypes = false,
}) async {
  final prefs = await SharedPreferences.getInstance();
  var typesJson = prefs.getString(DashboardPrefs.visitorTypesJsonKey) ?? '';
  if (typesJson.isEmpty || forceRefreshTypes) {
    typesJson = await ref.read(homeRepositoryProvider).fetchVisitorTypesJson(residenceUuid);
    await DashboardPrefs.setVisitorTypesJson(typesJson);
  }
  final types = parseVisitorTypeOptions(typesJson);
  final units = await ref.read(registerRepositoryProvider).fetchUnitsForResidence(residenceUuid);
  return RegisterVisitData(types: types, units: units);
}
