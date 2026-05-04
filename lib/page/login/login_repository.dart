import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/auth_prefs.dart';

/// Mirrors Android `RetrofitListAPI.sessionAPI` + Firebase token registration.
class LoginRepository {
  LoginRepository(this._dio);

  final Dio _dio;
  static const _uuid = Uuid();

  Future<void> signIn({
    required String identifier,
    required String challenge,
    required String regionCode,
    String firebaseToken = '',
  }) async {
    await AuthPrefs.setRegionCode(regionCode);
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        'admin/session',
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

      await AuthPrefs.setSession(
        sessionToken: token,
        profileUuid: profileUuid,
        userName: name,
        regionCode: regionCode,
      );

      final deviceUuid = _uuid.v4();
      try {
        await _dio.post<Map<String, dynamic>>(
          'data/user_firebase_tokens',
          data: <String, dynamic>{
            'uuid': deviceUuid,
            'firebase_token': firebaseToken,
            'user_profile_uuid': profileUuid,
            'is_valid': '1',
          },
        );
      } catch (_) {
        await AuthPrefs.clearSession();
        rethrow;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        throw LoginApiException('Invalid username / password');
      }
      throw LoginApiException(e.message ?? 'Network error');
    }
  }
}

final class LoginApiException implements Exception {
  LoginApiException(this.message);
  final String message;
}
