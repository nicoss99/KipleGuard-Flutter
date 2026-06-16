import '../../../core/device/login_device_info.dart';
import '../../../page/auth/guard_models.dart';
import '../../../page/auth/guard_pin_verify_result.dart';

/// Guard auth & profile API (login, logout, me, residences).
abstract interface class GuardAuthRepository {
  Future<GuardLoginResult> login({
    required String emailOrPhone,
    required String password,
    required LoginDeviceInfo device,
    bool isProceed = false,
  });

  Future<void> logout();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  Future<GuardMeResult> fetchMe();

  Future<GuardResidencesResult> fetchResidences({String? currentResidenceUuid});

  /// POST `auth/verify-pin` with `{ pin, residence_uuid }`.
  /// Verified when `success` is true or `data.pin_verified` is true.
  Future<GuardPinVerifyResult> verifyPin(
    String pin, {
    required String residenceUuid,
  });
}
