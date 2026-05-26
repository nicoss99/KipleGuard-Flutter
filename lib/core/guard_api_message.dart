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

bool guardApiSuccess(Map<String, dynamic>? body) => body?['success'] == true;

Map<String, dynamic>? guardApiData(Map<String, dynamic>? body) {
  final data = body?['data'];
  return data is Map<String, dynamic> ? data : null;
}
