import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../service/api_service.dart';
import '../../guard_api_message.dart';
import 'guard_http_client.dart';

final guardHttpClientProvider = Provider<GuardHttpClient>(
  (ref) => DioGuardHttpClient(ref.watch(dioProvider)),
);

/// Dio-backed [GuardHttpClient] — single place for success checks and error mapping.
final class DioGuardHttpClient implements GuardHttpClient {
  DioGuardHttpClient(this._dio);

  final Dio _dio;

  @override
  Future<Map<String, dynamic>?> getJson(
    String path, {
    Map<String, dynamic>? query,
    String fallbackMessage = 'Request failed',
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
    return _requireSuccess(res, fallbackMessage);
  }

  @override
  Future<Map<String, dynamic>?> postJson(
    String path, {
    Object? data,
    String fallbackMessage = 'Request failed',
  }) async {
    final envelope = await postGuardEnvelope(
      path,
      data: data,
      fallbackMessage: fallbackMessage,
    );
    return envelope.data;
  }

  @override
  Future<({Map<String, dynamic>? data, String? message})> postGuardEnvelope(
    String path, {
    Object? data,
    String fallbackMessage = 'Request failed',
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(path, data: data);
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? fallbackMessage,
      );
    }
    return (data: guardApiData(body), message: body?['message'] as String?);
  }

  @override
  Future<Map<String, dynamic>?> postMultipart(
    String path, {
    required FormData data,
    String fallbackMessage = 'Request failed',
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      path,
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
    return _requireSuccess(res, fallbackMessage);
  }

  @override
  Future<dynamic> getRaw(String path, {Map<String, dynamic>? query}) async {
    final res = await _dio.get<dynamic>(path, queryParameters: query);
    return res.data;
  }

  Map<String, dynamic>? _requireSuccess(
    Response<Map<String, dynamic>> res,
    String fallbackMessage,
  ) {
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? fallbackMessage,
      );
    }
    return guardApiData(body);
  }
}
