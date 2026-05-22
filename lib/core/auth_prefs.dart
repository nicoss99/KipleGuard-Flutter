import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_logger.dart';
import 'dashboard_prefs.dart';

/// Session data persisted like Android `DBOthers` (userToken, userID, userName, …).
abstract final class AuthPrefs {
  static const sessionTokenKey = 'kiple_session_token';
  static const profileUuidKey = 'kiple_profile_uuid';
  static const userNameKey = 'kiple_user_name';
  static const regionCodeKey = 'kiple_region_code';
  static const userIdentityUuidKey = 'kiple_user_identity_uuid';
  static const userEmailKey = 'kiple_user_email';
  static const userPhoneKey = 'kiple_user_phone';
  static const userRolesJsonKey = 'kiple_user_roles_json';
  /// Local UUID for `PUT data/user_firebase_tokens/{uuid}` (Android `userFirebase`).
  static const userFirebaseRecordUuidKey = 'kiple_user_firebase_record_uuid';

  static String? _tokenCache;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _tokenCache = prefs.getString(sessionTokenKey);
    logBearerToken(reason: 'loaded from storage');
  }

  static bool get isLoggedInSync => (_tokenCache != null && _tokenCache!.isNotEmpty);

  static String? get sessionToken => _tokenCache;

  static Future<void> setSession({
    required String sessionToken,
    required String profileUuid,
    required String userName,
    required String regionCode,
    String? userIdentityUuid,
    String? userEmail,
    String? userPhone,
    String? userRolesJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sessionTokenKey, sessionToken);
    await prefs.setString(profileUuidKey, profileUuid);
    await prefs.setString(userNameKey, userName);
    await prefs.setString(regionCodeKey, regionCode);
    await _setOptional(prefs, userIdentityUuidKey, userIdentityUuid);
    await _setOptional(prefs, userEmailKey, userEmail);
    await _setOptional(prefs, userPhoneKey, userPhone);
    await _setOptional(prefs, userRolesJsonKey, userRolesJson);
    _tokenCache = sessionToken;
    logBearerToken(reason: 'session set');
  }

  static Future<void> _setOptional(SharedPreferences prefs, String key, String? value) async {
    if (value == null || value.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }

  static Future<void> setRegionCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(regionCodeKey, code);
  }

  static Future<String?> getRegionCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(regionCodeKey);
  }

  static Future<String?> readUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  static Future<String?> readUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  static Future<String?> readUserRolesJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userRolesJsonKey);
  }

  static Future<String?> readProfileUuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(profileUuidKey);
  }

  static Future<String?> readUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPhoneKey);
  }

  static Future<String?> readUserIdentityUuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdentityUuidKey);
  }

  static Future<String?> readUserFirebaseRecordUuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userFirebaseRecordUuidKey);
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, name);
  }

  static Future<void> setUserFirebaseRecordUuid(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userFirebaseRecordUuidKey, uuid);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionTokenKey);
    await prefs.remove(profileUuidKey);
    await prefs.remove(userNameKey);
    await prefs.remove(userIdentityUuidKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userPhoneKey);
    await prefs.remove(userRolesJsonKey);
    await prefs.remove(userFirebaseRecordUuidKey);
    _tokenCache = null;
    logBearerToken(reason: 'session cleared');
    await DashboardPrefs.clear();
  }

  /// Debug only — logs the full bearer token (filter DevTools by `KipleGuard.Auth`).
  static void logBearerToken({String? reason}) {
    if (!kDebugMode) return;
    final prefix = reason == null ? '' : '($reason) ';
    final token = _tokenCache;
    if (token == null || token.isEmpty) {
      AppLog.debug('${prefix}Bearer token: <empty>', tag: 'KipleGuard.Auth');
      return;
    }
    AppLog.debug('${prefix}Bearer token: $token', tag: 'KipleGuard.Auth');
  }
}
