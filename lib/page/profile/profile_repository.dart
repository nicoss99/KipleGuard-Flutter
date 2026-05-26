import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/guard_api_message.dart';
import '../../core/api/contracts/guard_auth_repository.dart';
import '../auth/guard_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(guardRepositoryProvider)),
);

class ProfileRepository {
  ProfileRepository(this._guard);

  final GuardAuthRepository _guard;

  Future<void> logout() => _guard.logout();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) =>
      _guard.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
}

String profileApiErrorMessage(DioException e) => guardApiMessage(e);

final class ProfileApiException implements Exception {
  ProfileApiException(this.message);
  final String message;
}
