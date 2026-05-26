import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/dashboard_prefs.dart';
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
  required bool officeMode,
}) async {
  final repo = ref.read(registerRepositoryProvider);
  List<RegisterVisitorTypeOption> types = const [];
  try {
    types = await repo.fetchVisitorTypes(residenceUuid);
  } catch (_) {
    final prefs = await SharedPreferences.getInstance();
    final typesJson = prefs.getString(DashboardPrefs.visitorTypesJsonKey) ?? '';
    types = parseVisitorTypeOptions(typesJson);
  }
  final units = await repo.fetchUnitsForResidence(
    residenceUuid,
    officeMode: officeMode,
  );
  return RegisterVisitData(types: types, units: units);
}
