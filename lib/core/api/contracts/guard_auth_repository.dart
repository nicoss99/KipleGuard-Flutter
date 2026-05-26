import '../../../core/device/login_device_info.dart';
import '../../../page/auth/guard_models.dart';

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

  Future<List<GuardResidence>> fetchResidences();
}
