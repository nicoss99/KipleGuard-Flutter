import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_config.dart';
import '../../core/guard_api_message.dart';
import '../auth/guard_repository.dart';
import '../../service/api_service.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(dioProvider), ref.watch(guardRepositoryProvider)),
);

class ProfileRepository {
  ProfileRepository(this._dio, this._guard);

  final Dio _dio;
  final GuardRepository _guard;

  Future<void> logout() => _guard.logout();

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

String profileApiErrorMessage(DioException e) => guardApiMessage(e);

final class ProfileApiException implements Exception {
  ProfileApiException(this.message);
  final String message;
}
