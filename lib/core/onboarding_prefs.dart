import 'package:shared_preferences/shared_preferences.dart';

/// First-install onboarding completion (Android `DBOthers` "onboardingJourney").
abstract final class OnboardingPrefs {
  static const key = 'onboarding_complete_v1';

  static bool? _cached;

  /// Call once at startup before building [GoRouter].
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _cached = prefs.getBool(key) ?? false;
  }

  /// Used by redirects; valid after [load] or [setComplete].
  static bool get isCompleteSync => _cached ?? false;

  static Future<void> setComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
    _cached = true;
  }
}
