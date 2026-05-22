import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/app_config.dart';

/// Android `RetrofitListAPI` profile + sign-out + change-password calls.
class ProfileRepository {
  ProfileRepository(this._dio);

  final Dio _dio;

  Future<void> updateProfileName({
    required String profileUuid,
    required String name,
  }) async {
    await _dio.put<void>(
      AppConfig.userProfilePath(profileUuid),
      data: <String, dynamic>{'uuid': profileUuid, 'name': name},
    );
  }

  Future<void> invalidateFirebaseToken(String recordUuid) async {
    await _dio.put<void>(
      AppConfig.userFirebaseTokenPath(recordUuid),
      data: <String, dynamic>{'is_valid': '0'},
    );
  }

  Future<void> changePassword({
    required String identityUuid,
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      AppConfig.identityChallengePath(identityUuid),
      data: <String, dynamic>{
        'old_challenge': oldPassword,
        'challenge': newPassword,
      },
    );
  }
}

String profileApiErrorMessage(DioException e) {
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
  return e.message ?? 'Something went wrong';
}

final class ProfileApiException implements Exception {
  ProfileApiException(this.message);
  final String message;
}
