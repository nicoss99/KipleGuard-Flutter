import 'package:dio/dio.dart';

import 'network/dio_network.dart';
import 'offline/offline_messages.dart';

/// Parses `{ "success": false, "message": "..." }` guard API errors.
String guardApiMessage(DioException e, {String fallback = 'Something went wrong'}) {
  final data = e.response?.data;
  if (data is Map<String, dynamic>) {
    final msg = data['message'];
    if (msg is String && msg.isNotEmpty) return msg;
  }
  if (isNetworkError(e)) return offlineNoConnectionMessage();
  return fallback;
}

bool guardApiSuccess(Map<String, dynamic>? body) =>
    guardApiTruthy(body?['success']);

bool guardApiTruthy(dynamic value) {
  if (value == true || value == 1) return true;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}

Map<String, dynamic>? asStringKeyedMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

/// `verify-pin` succeeds when `success` is true or `data.pin_verified` is true.
bool guardPinVerifySuccess(Map<String, dynamic>? body) {
  if (body == null) return false;
  if (guardApiTruthy(body['success'])) return true;
  if (guardApiTruthy(body['pin_verified'])) return true;
  final data = guardApiData(body);
  if (data == null) return false;
  return guardApiTruthy(data['pin_verified']) ||
      guardApiTruthy(data['verified']);
}

Map<String, dynamic>? guardApiData(Map<String, dynamic>? body) {
  if (body == null) return null;
  return asStringKeyedMap(body['data']);
}
