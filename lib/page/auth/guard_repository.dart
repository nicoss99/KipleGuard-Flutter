import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/guard_api_paths.dart';
import '../../core/auth_prefs.dart';
import '../../core/residence_prefs.dart';
import '../../core/guard_api_message.dart';
import '../../service/api_service.dart';
import '../login/login_repository.dart';
import 'guard_models.dart';

final guardRepositoryProvider = Provider<GuardRepository>(
  (ref) => GuardRepository(ref.watch(dioProvider)),
);

class GuardRepository {
  GuardRepository(this._dio);

  final Dio _dio;

  Future<GuardLoginResult> login({
    required String emailOrPhone,
    required String password,
    bool isProceed = false,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        GuardApiPaths.login,
        data: <String, dynamic>{
          'email_or_phone': emailOrPhone,
          'password': password,
          if (isProceed) 'is_proceed': 1,
        },
      );
      final body = res.data;
      if (!guardApiSuccess(body)) {
        throw LoginApiException(body?['message'] as String? ?? 'Login failed');
      }
      final data = guardApiData(body);
      if (data == null) throw LoginApiException('Invalid login payload');

      final token = data['token'] as String?;
      final guardJson = data['guard'] as Map<String, dynamic>?;
      if (token == null || token.isEmpty || guardJson == null) {
        throw LoginApiException('Invalid login payload');
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
      throw LoginApiException(guardApiMessage(e, fallback: 'Invalid username / password'));
    }
  }

  Future<void> logout() async {
    final res = await _dio.post<Map<String, dynamic>>(GuardApiPaths.logout);
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? 'Logout failed',
      );
    }
  }

  Future<GuardMeResult> fetchMe() async {
    final res = await _dio.get<Map<String, dynamic>>(GuardApiPaths.me);
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? 'Failed to load profile',
      );
    }
    final data = guardApiData(body);
    if (data == null) throw StateError('Invalid profile payload');
    final guardJson = data['guard'] as Map<String, dynamic>?;
    if (guardJson == null) throw StateError('Invalid profile payload');
    final guard = GuardProfile.fromJson(guardJson);
    final residences = _parseResidences(data['residences']);
    await AuthPrefs.updateGuardProfile(guard: guard, residences: residences);
    return GuardMeResult(guard: guard, residences: residences);
  }

  Future<List<GuardResidence>> fetchResidences() async {
    final res = await _dio.get<Map<String, dynamic>>(GuardApiPaths.residences);
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? 'Failed to load residences',
      );
    }
    final data = guardApiData(body);
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
