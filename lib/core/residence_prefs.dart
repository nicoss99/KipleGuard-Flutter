import 'package:shared_preferences/shared_preferences.dart';

import '../page/auth/guard_models.dart';
import '../page/select_site/guard_residence_choices.dart';
import 'dashboard_prefs.dart';

/// Selected guard residence UUID (`residenceUuid` + legacy `userResidenceID`).
abstract final class ResidencePrefs {
  static const residenceUuidKey = 'residenceUuid';

  static Future<void> saveResidenceUuid(String uuid) async {
    if (uuid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(residenceUuidKey, uuid);
    await prefs.setString(DashboardPrefs.userResidenceIdKey, uuid);
  }

  static Future<String?> readResidenceUuid() async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString(residenceUuidKey);
    if (uuid != null && uuid.isNotEmpty) return uuid;
    return prefs.getString(DashboardPrefs.userResidenceIdKey);
  }

  static Future<void> clearResidenceUuid() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(residenceUuidKey);
  }

  /// Persists UUID and full dashboard site fields from a guard residence.
  static Future<void> persistGuardResidence(GuardResidence residence) async {
    await saveResidenceUuid(residence.uuid);
    final choices = guardResidencesToChoices([residence]);
    if (choices.isNotEmpty) await choices.first.persist();
  }

  /// After login / me: keep saved UUID if still valid, else first residence.
  static Future<void> applyDefaultFromResidences(List<GuardResidence> residences) async {
    if (residences.isEmpty) return;
    final saved = await readResidenceUuid();
    final pick = residences.firstWhere(
      (r) => r.uuid == saved,
      orElse: () => residences.first,
    );
    await persistGuardResidence(pick);
  }
}
