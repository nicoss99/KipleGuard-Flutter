import 'package:shared_preferences/shared_preferences.dart';

/// Session data persisted like Android `DBOthers` (userToken, userID, userName, …).
abstract final class AuthPrefs {
  static const sessionTokenKey = 'kiple_session_token';
  static const profileUuidKey = 'kiple_profile_uuid';
  static const userNameKey = 'kiple_user_name';
  static const regionCodeKey = 'kiple_region_code';

  static String? _tokenCache;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _tokenCache = prefs.getString(sessionTokenKey);
  }

  static bool get isLoggedInSync => (_tokenCache != null && _tokenCache!.isNotEmpty);

  static String? get sessionToken => _tokenCache;

  static Future<void> setSession({
    required String sessionToken,
    required String profileUuid,
    required String userName,
    required String regionCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sessionTokenKey, sessionToken);
    await prefs.setString(profileUuidKey, profileUuid);
    await prefs.setString(userNameKey, userName);
    await prefs.setString(regionCodeKey, regionCode);
    _tokenCache = sessionToken;
  }

  static Future<void> setRegionCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(regionCodeKey, code);
  }

  static Future<String?> getRegionCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(regionCodeKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionTokenKey);
    await prefs.remove(profileUuidKey);
    await prefs.remove(userNameKey);
    _tokenCache = null;
  }
}
