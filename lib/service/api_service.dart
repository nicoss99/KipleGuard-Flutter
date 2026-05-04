import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/app_config.dart';
import '../core/app_flavor.dart';
import '../core/auth_prefs.dart';

final dioProvider = Provider<Dio>((ref) {
  final flavor = ref.watch(appFlavorProvider);
  final base = AppConfig.baseUrl(flavor);
  final normalized = base.endsWith('/') ? base : '$base/';
  final dio = Dio(
    BaseOptions(
      baseUrl: normalized,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: <String, dynamic>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
        'X-Application-Key': AppConfig.xApplicationKey(flavor),
      },
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = AuthPrefs.sessionToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );
  return dio;
});
