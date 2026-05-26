import 'dart:io';

import 'package:dio/dio.dart';

bool isNetworkError(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError) {
    return true;
  }

  if (e.error != null && _isConnectivityFailureText(e.error.toString())) {
    return true;
  }

  if (_isConnectivityFailureText(e.message)) return true;

  if (e.type == DioExceptionType.unknown) {
    if (e.error is SocketException || e.error is IOException) return true;
  }

  return false;
}

bool isNetworkErrorObject(Object? e) => e is DioException && isNetworkError(e);

/// True for DNS failures, timeouts, no network, and similar (any error type).
bool isConnectivityFailure(Object? e) {
  if (e == null) return false;
  if (isNetworkErrorObject(e)) return true;
  if (e is SocketException || e is IOException) return true;
  return _isConnectivityFailureText(e.toString());
}

bool _isConnectivityFailureText(String? text) {
  if (text == null || text.isEmpty) return false;
  final lower = text.toLowerCase();
  return lower.contains('failed host lookup') ||
      lower.contains('no address associated with hostname') ||
      lower.contains('network is unreachable') ||
      lower.contains('connection refused') ||
      lower.contains('connection reset') ||
      lower.contains('connection timed out') ||
      lower.contains('connection closed') ||
      lower.contains('socketexception') ||
      lower.contains('clientexception') ||
      lower.contains('handshakeexception') ||
      lower.contains('unable to resolve host') ||
      lower.contains('errno = 7') ||
      lower.contains('errno = 8') ||
      lower.contains('software caused connection abort') ||
      lower.contains('network error');
}
