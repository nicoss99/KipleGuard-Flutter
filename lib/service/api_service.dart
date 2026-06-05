import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/app_config.dart';
import '../core/app_flavor.dart';
import '../core/auth/session_expired_handler.dart';
import '../core/auth_prefs.dart';
import 'api_logging_interceptor.dart';

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
        'Accept-Encoding': 'deflate',
        'Content-Type': 'application/json; charset=utf-8',
        'X-Application-Key': AppConfig.xApplicationKey(flavor),
      },
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final path = options.uri.path;
        final token = AuthPrefs.sessionToken;
        if (requiresGuardAuth(path) && (token == null || token.isEmpty)) {
          handleUnauthorizedApiResponse(ref, options);
          handler.reject(
            DioException(
              requestOptions: options,
              message: 'Session expired',
              type: DioExceptionType.cancel,
            ),
          );
          return;
        }
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.statusCode == 401) {
          handleUnauthorizedApiResponse(ref, response.requestOptions);
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              message: 'Session expired',
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
        if (isSessionSupersededPayload(response.data)) {
          handleSessionSupersededResponse(ref, response.requestOptions, response.data);
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              message: 'Session expired',
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
        handler.next(response);
      },
      onError: (err, handler) {
        if (isSessionSupersededError(err)) {
          handleSessionSupersededResponse(ref, err.requestOptions, err.response?.data);
        } else if (err.response?.statusCode == 401 &&
            requiresGuardAuth(err.requestOptions.uri.path) &&
            !sessionExpiredFlowInProgress) {
          handleUnauthorizedApiResponse(ref, err.requestOptions);
        }
        handler.next(err);
      },
    ),
  );
  dio.interceptors.add(ApiLoggingInterceptor());
  return dio;
});
