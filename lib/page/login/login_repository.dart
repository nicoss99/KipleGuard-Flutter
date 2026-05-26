import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../auth/guard_models.dart';
import '../auth/guard_repository.dart';

final loginRepositoryProvider = Provider<LoginRepository>(
  (ref) => LoginRepository(ref.watch(guardRepositoryProvider)),
);

/// Guard auth login (`POST api/v1/guard/auth/login`).
class LoginRepository {
  LoginRepository(this._guard);

  final GuardRepository _guard;

  Future<GuardLoginResult> signIn({
    required String identifier,
    required String challenge,
    bool isProceed = false,
    String firebaseToken = '',
  }) =>
      _guard.login(
        emailOrPhone: identifier,
        password: challenge,
        isProceed: isProceed,
      );
}

final class LoginApiException implements Exception {
  LoginApiException(this.message);
  final String message;
}
