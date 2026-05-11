import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_logger.dart';
import '../../service/api_service.dart';
import 'login_fcm_token.dart';
import 'login_repository.dart';

final loginRepositoryProvider = Provider<LoginRepository>(
  (ref) => LoginRepository(ref.watch(dioProvider)),
);

class LoginUiState {
  const LoginUiState({
    this.loading = false,
    this.fieldError,
    this.apiError,
  });

  final bool loading;
  /// `'region'` | `'credentials'` | null
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

  void requireRegion() {
    state = LoginUiState(
      loading: state.loading,
      fieldError: 'region',
      apiError: null,
    );
  }

  void clearFieldErrors() {
    state = state.copyWith(clearFieldError: true, clearApiError: true);
  }

  Future<bool> signIn({
    required String identifier,
    required String password,
    required String regionCode,
    String firebaseToken = '',
  }) async {
    if (regionCode.isEmpty) {
      state = state.copyWith(fieldError: 'region');
      return false;
    }
    if (identifier.isEmpty || password.isEmpty) {
      state = state.copyWith(fieldError: 'credentials');
      return false;
    }

    state = state.copyWith(
      loading: true,
      clearFieldError: true,
      clearApiError: true,
    );
    try {
      final fcm = firebaseToken.isNotEmpty
          ? firebaseToken
          : await readLoginFirebaseMessagingToken();
      await ref.read(loginRepositoryProvider).signIn(
            identifier: identifier,
            challenge: password,
            regionCode: regionCode,
            firebaseToken: fcm,
          );
      AppLog.track('sign_in_success', screen: 'Login', attributes: {'region': regionCode});
      state = state.copyWith(loading: false);
      return true;
    } on LoginApiException catch (e) {
      state = state.copyWith(loading: false, apiError: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(loading: false, apiError: 'Something went wrong');
      return false;
    }
  }
}

final loginNotifierProvider = NotifierProvider<LoginNotifier, LoginUiState>(
  LoginNotifier.new,
);
