import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api/client/dio_guard_http_client.dart';
import '../../core/api/client/guard_http_client.dart';
import '../../core/api/contracts/guard_auth_repository.dart';
import '../../core/api/messages/api_message_catalog.dart';
import '../../core/api/messages/localized_api_message_catalog.dart';
import '../../core/device/login_device_info.dart';
import '../../core/auth_prefs.dart';
import '../../core/guard_api_message.dart';
import '../../core/guard_api_paths.dart';
import '../../core/residence_prefs.dart';
import '../login/login_repository.dart';
import 'guard_models.dart';

final guardRepositoryProvider = Provider<GuardAuthRepository>(
  (ref) => GuardRepository(
    ref.watch(guardHttpClientProvider),
    ref.watch(apiMessageCatalogProvider),
  ),
);

final class GuardRepository implements GuardAuthRepository {
  GuardRepository(this._client, this._messages);

  final GuardHttpClient _client;
  final ApiMessageCatalog _messages;

  @override
  Future<GuardLoginResult> login({
    required String emailOrPhone,
    required String password,
    required LoginDeviceInfo device,
    bool isProceed = false,
  }) async {
    try {
      final data = await _client.postJson(
        GuardApiPaths.login,
        data: <String, dynamic>{
          'email_or_phone': emailOrPhone,
          'password': password,
          ...device.toLoginJson(),
          if (isProceed) 'is_proceed': 1,
        },
        fallbackMessage: _messages.loginFailed,
      );
      if (data == null) throw LoginApiException(_messages.invalidLoginPayload);

      final token = data['token'] as String?;
      final guardJson = data['guard'] as Map<String, dynamic>?;
      if (token == null || token.isEmpty || guardJson == null) {
        throw LoginApiException(_messages.invalidLoginPayload);
      }

      final guard = GuardProfile.fromJson(guardJson);
      final residences = _parseResidences(data['residences']);
      final switchRaw = data['switch_device'] as Map<String, dynamic>?;
      final switchDevice = GuardSwitchDevice.fromJson(switchRaw);

      await AuthPrefs.setGuardSession(
        sessionToken: token,
        guard: guard,
        residences: residences,
      );

      return GuardLoginResult(
        switchDevice: switchDevice.isSwitchDevice ? switchDevice : null,
      );
    } on DioException catch (e) {
      throw LoginApiException(guardApiMessage(e, fallback: _messages.invalidCredentials));
    }
  }

  @override
  Future<void> logout() async {
    await _client.postJson(GuardApiPaths.logout, fallbackMessage: _messages.logoutFailed);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _client.postJson(
      GuardApiPaths.changePassword,
      data: <String, dynamic>{
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
      fallbackMessage: _messages.requestFailed,
    );
  }

  @override
  Future<GuardMeResult> fetchMe() async {
    final data = await _client.getJson(
      GuardApiPaths.me,
      fallbackMessage: _messages.profileLoadFailed,
    );
    if (data == null) throw StateError(_messages.invalidLoginPayload);
    final guardJson = data['guard'] as Map<String, dynamic>?;
    if (guardJson == null) throw StateError(_messages.invalidLoginPayload);
    final guard = GuardProfile.fromJson(guardJson);
    final residences = _parseResidences(data['residences']);
    await AuthPrefs.updateGuardProfile(guard: guard, residences: residences);
    return GuardMeResult(guard: guard, residences: residences);
  }

  @override
  Future<List<GuardResidence>> fetchResidences() async {
    final data = await _client.getJson(
      GuardApiPaths.residences,
      fallbackMessage: _messages.residencesLoadFailed,
    );
    final list = _parseResidences(data?['residences']);
    await AuthPrefs.cacheGuardResidences(list);
    final current = await ResidencePrefs.readResidenceUuid();
    if (current == null || current.isEmpty) {
      await ResidencePrefs.applyDefaultFromResidences(list);
    }
    return list;
  }

  List<GuardResidence> _parseResidences(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GuardResidence.fromJson)
        .where((r) => r.uuid.isNotEmpty)
        .toList();
  }
}
