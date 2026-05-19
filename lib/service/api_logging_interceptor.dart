import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/app_logger.dart';
import 'api_log_format.dart';

/// Logs every Dio request/response through [AppLog] (debug/profile builds only).
class ApiLoggingInterceptor extends Interceptor {
  static const _tag = 'KipleGuard.API';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      AppLog.debug(ApiLogFormat.request(options), tag: _tag);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      AppLog.debug(ApiLogFormat.response(response), tag: _tag);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      AppLog.warning(
        ApiLogFormat.error(err),
        tag: _tag,
        error: err,
        stackTrace: err.stackTrace,
      );
    }
    handler.next(err);
  }
}
