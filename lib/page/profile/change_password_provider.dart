import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/auth_prefs.dart';
import 'change_password_validator.dart';
import 'profile_provider.dart';
import 'profile_repository.dart';

class ChangePasswordState {
  const ChangePasswordState({
    this.loading = false,
    this.validation = const ChangePasswordValidation(),
    this.apiError,
  });

  final bool loading;
  final ChangePasswordValidation validation;
  final String? apiError;

  ChangePasswordState copyWith({
    bool? loading,
    ChangePasswordValidation? validation,
    String? apiError,
    bool clearErrors = false,
  }) {
    return ChangePasswordState(
      loading: loading ?? this.loading,
      validation: clearErrors ? const ChangePasswordValidation() : (validation ?? this.validation),
      apiError: clearErrors ? null : (apiError ?? this.apiError),
    );
  }
}

final changePasswordProvider =
    NotifierProvider<ChangePasswordNotifier, ChangePasswordState>(ChangePasswordNotifier.new);

class ChangePasswordNotifier extends Notifier<ChangePasswordState> {
  @override
  ChangePasswordState build() => const ChangePasswordState();

  void clearValidation() {
    if (state.validation.hasError || state.apiError != null) {
      state = state.copyWith(clearErrors: true);
    }
  }

  Future<bool> submit({
    required String current,
    required String newPass,
    required String confirm,
  }) async {
    final validation = ChangePasswordValidation.validate(
      current: current,
      newPass: newPass,
      confirm: confirm,
    );

    if (validation.hasError) {
      state = ChangePasswordState(validation: validation);
      return false;
    }

    state = const ChangePasswordState(loading: true);
    try {
      final identityUuid = await AuthPrefs.readUserIdentityUuid();
      if (identityUuid == null || identityUuid.isEmpty) {
        throw ProfileApiException('Missing identity');
      }
      await ref.read(profileRepositoryProvider).changePassword(
            identityUuid: identityUuid,
            oldPassword: current,
            newPassword: newPass,
          );
      state = const ChangePasswordState();
      return true;
    } on DioException catch (e) {
      state = ChangePasswordState(loading: false, apiError: profileApiErrorMessage(e));
      return false;
    } on ProfileApiException catch (e) {
      state = ChangePasswordState(loading: false, apiError: e.message);
      return false;
    } catch (_) {
      state = const ChangePasswordState(loading: false, apiError: 'Something went wrong');
      return false;
    }
  }
}
