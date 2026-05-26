import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../page/auth/guard_models.dart';
import 'app_logger.dart';
import 'dashboard_prefs.dart';
import 'residence_prefs.dart';

/// Session data persisted like Android `DBOthers` (userToken, userID, userName, …).
abstract final class AuthPrefs {
  static const sessionTokenKey = 'kiple_session_token';
  static const profileUuidKey = 'kiple_profile_uuid';
  static const userNameKey = 'kiple_user_name';
  static const userIdentityUuidKey = 'kiple_user_identity_uuid';
  static const userEmailKey = 'kiple_user_email';
  static const userPhoneKey = 'kiple_user_phone';
  static const userRolesJsonKey = 'kiple_user_roles_json';
  /// Local UUID for `PUT data/user_firebase_tokens/{uuid}` (Android `userFirebase`).
  static const userFirebaseRecordUuidKey = 'kiple_user_firebase_record_uuid';
  static const guardIdKey = 'kiple_guard_id';
  static const guardRoleKey = 'kiple_guard_role';
  static const profileImageUrlKey = 'kiple_profile_image_url';
  static const residencesJsonKey = 'kiple_guard_residences_json';

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
    String? userIdentityUuid,
    String? userEmail,
    String? userPhone,
    String? userRolesJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sessionTokenKey, sessionToken);
    await prefs.setString(profileUuidKey, profileUuid);
    await prefs.setString(userNameKey, userName);
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

  static Future<void> setGuardSession({
    required String sessionToken,
    required GuardProfile guard,
    required List<GuardResidence> residences,
  }) async {
    await setSession(
      sessionToken: sessionToken,
      profileUuid: guard.id.toString(),
      userName: guard.name,
      userEmail: guard.email.isEmpty ? null : guard.email,
      userPhone: guard.phone.isEmpty ? null : guard.phone,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(guardIdKey, guard.id);
    await prefs.setString(guardRoleKey, guard.role);
    await _setOptional(prefs, profileImageUrlKey, guard.profileImageUrl);
    await prefs.setString(
      residencesJsonKey,
      jsonEncode(residences.map((r) => r.toJson()).toList()),
    );
    await ResidencePrefs.applyDefaultFromResidences(residences);
  }

  static Future<void> updateGuardProfile({
    required GuardProfile guard,
    required List<GuardResidence> residences,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, guard.name);
    await _setOptional(prefs, userEmailKey, guard.email.isEmpty ? null : guard.email);
    await _setOptional(prefs, userPhoneKey, guard.phone.isEmpty ? null : guard.phone);
    await _setOptional(prefs, profileImageUrlKey, guard.profileImageUrl);
    await prefs.setString(
      residencesJsonKey,
      jsonEncode(residences.map((r) => r.toJson()).toList()),
    );
  }

  static Future<void> cacheGuardResidences(List<GuardResidence> residences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      residencesJsonKey,
      jsonEncode(residences.map((r) => r.toJson()).toList()),
    );
  }

  static Future<List<GuardResidence>> readGuardResidences() async {
    final raw = await readResidencesJson();
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(GuardResidence.fromJson)
          .where((r) => r.uuid.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<String?> readResidencesJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(residencesJsonKey);
  }

  static Future<String?> readProfileImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(profileImageUrlKey);
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
    await prefs.remove(guardIdKey);
    await prefs.remove(guardRoleKey);
    await prefs.remove(profileImageUrlKey);
    await prefs.remove(residencesJsonKey);
    await ResidencePrefs.clearResidenceUuid();
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
