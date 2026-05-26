import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_logger.dart';
import '../../core/auth_prefs.dart';
import '../auth/guard_models.dart';
import 'login_fcm_token.dart';
import 'login_repository.dart';

class LoginUiState {
  const LoginUiState({
    this.loading = false,
    this.fieldError,
    this.apiError,
  });

  final bool loading;
  final String? fieldError;
  final String? apiError;

  LoginUiState copyWith({
    bool? loading,
    String? fieldError,
    String? apiError,
    bool clearFieldError = false,
    bool clearApiError = false,
  }) {
    return LoginUiState(
      loading: loading ?? this.loading,
      fieldError: clearFieldError ? null : (fieldError ?? this.fieldError),
      apiError: clearApiError ? null : (apiError ?? this.apiError),
    );
  }
}

class LoginNotifier extends Notifier<LoginUiState> {
  @override
  LoginUiState build() => const LoginUiState();

  void clearFieldErrors() {
    state = state.copyWith(clearFieldError: true, clearApiError: true);
  }

  /// `null` = failed; otherwise login succeeded (may include switch-device prompt).
  Future<GuardLoginResult?> signIn({
    required String identifier,
    required String password,
    String firebaseToken = '',
  }) =>
      _login(
        identifier: identifier,
        password: password,
        isProceed: false,
        firebaseToken: firebaseToken,
      );

  /// Re-login after user confirms switch device (`is_proceed`).
  Future<GuardLoginResult?> confirmSwitchDevice({
    required String identifier,
    required String password,
    String firebaseToken = '',
  }) =>
      _login(
        identifier: identifier,
        password: password,
        isProceed: true,
        firebaseToken: firebaseToken,
      );

  Future<void> cancelPendingSwitchDevice() async {
    await AuthPrefs.clearSession();
    state = state.copyWith(clearFieldError: true, clearApiError: true);
  }

  Future<GuardLoginResult?> _login({
    required String identifier,
    required String password,
    required bool isProceed,
    String firebaseToken = '',
  }) async {
    if (identifier.isEmpty || password.isEmpty) {
      state = state.copyWith(fieldError: 'credentials');
      return null;
    }

    state = state.copyWith(loading: true, clearFieldError: true, clearApiError: true);
    try {
      if (!isProceed) await readLoginFirebaseMessagingToken();
      final result = await ref.read(loginRepositoryProvider).signIn(
            identifier: identifier,
            challenge: password,
            isProceed: isProceed,
            firebaseToken: firebaseToken,
          );
      AppLog.track('sign_in_success', screen: 'Login', attributes: {'is_proceed': isProceed});
      state = state.copyWith(loading: false);
      return result;
    } on LoginApiException {
      state = state.copyWith(loading: false, fieldError: 'credentials');
      return null;
    } catch (_) {
      state = state.copyWith(loading: false, fieldError: 'credentials');
      return null;
    }
  }
}

final loginNotifierProvider = NotifierProvider<LoginNotifier, LoginUiState>(
  LoginNotifier.new,
);
