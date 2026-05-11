import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_config.dart';
import '../../core/app_logger.dart';
import '../../core/auth_prefs.dart';

/// Mirrors `RetrofitListAPI.sessionAPI` + `POST data/user_firebase_tokens` ([LoginActivity]).
class LoginRepository {
  LoginRepository(this._dio);

  final Dio _dio;
  static final _uuid = Uuid();

  Future<void> signIn({
    required String identifier,
    required String challenge,
    required String regionCode,
    String firebaseToken = '',
  }) async {
    await AuthPrefs.setRegionCode(regionCode);
    try {
      AppLog.info('Sign-in API request', tag: 'LoginApi');
      final res = await _dio.post<Map<String, dynamic>>(
        AppConfig.sessionApiPath,
        data: <String, dynamic>{
          'identifier': identifier,
          'challenge': challenge,
        },
      );
      final data = res.data;
      if (data == null) throw Exception('Empty response');

      final token = data['session_token'] as String?;
      final profile = data['profile'] as Map<String, dynamic>?;
      if (token == null || profile == null) {
        throw Exception('Invalid session payload');
      }

      final profileUuid = profile['uuid'] as String?;
      final name = profile['name'] as String? ?? '';
      if (profileUuid == null) throw Exception('Invalid profile');

      final identities = data['identities'];
      String? identityUuid;
      if (identities is List && identities.isNotEmpty) {
        final first = identities.first;
        if (first is Map<String, dynamic>) {
          identityUuid = first['uuid'] as String?;
        }
      }

      final email = profile['email'] as String? ?? '';
      final phone = profile['phone'] as String? ?? '';
      String? rolesJson;
      final roles = profile['roles'];
      if (roles != null) {
        rolesJson = jsonEncode(roles);
      }

      AppLog.info('Sign-in API response OK', tag: 'LoginApi');
      await AuthPrefs.setSession(
        sessionToken: token,
        profileUuid: profileUuid,
        userName: name,
        regionCode: regionCode,
        userIdentityUuid: identityUuid,
        userEmail: email.isEmpty ? null : email,
        userPhone: phone.isEmpty ? null : phone,
        userRolesJson: rolesJson,
      );

      final tokenForFirebase = firebaseToken.isEmpty ? '' : firebaseToken;

      try {
        await _dio.post<Map<String, dynamic>>(
          AppConfig.userFirebaseTokensPath,
          data: <String, dynamic>{
            'uuid': _uuid.v4(),
            'firebase_token': tokenForFirebase,
            'user_profile_uuid': profileUuid,
            'is_valid': '1',
          },
        );
      } catch (_) {
        await AuthPrefs.clearSession();
        rethrow;
      }
    } on DioException catch (e) {
      final message = _loginErrorMessage(e);
      AppLog.warning('Sign-in API failed', tag: 'LoginApi', data: {'message': message});
      throw LoginApiException(message);
    }
  }
}

String _loginErrorMessage(DioException e) {
  final response = e.response;
  if (response == null) return e.message ?? 'Network error';

  final data = response.data;
  if (data is Map<String, dynamic>) {
    final errField = data['error'];
    if (errField is String && errField.isNotEmpty) {
      try {
        final inner = jsonDecode(errField) as Map<String, dynamic>;
        final msg = inner['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      } catch (_) {}
    }
    final top = data['message'];
    if (top is String && top.isNotEmpty) return top;
  }

  final code = response.statusCode;
  if (code == 401 || code == 400) return 'Invalid username / password';
  return e.message ?? 'Something went wrong';
}

final class LoginApiException implements Exception {
  LoginApiException(this.message);
  final String message;
}
