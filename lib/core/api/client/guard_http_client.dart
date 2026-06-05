import 'package:dio/dio.dart';

/// HTTP transport for Guard / legacy JSON APIs (DIP — repositories depend on this).
abstract interface class GuardHttpClient {
  Future<Map<String, dynamic>?> getJson(
    String path, {
    Map<String, dynamic>? query,
    String fallbackMessage,
  });

  Future<Map<String, dynamic>?> postJson(
    String path, {
    Object? data,
    String fallbackMessage = 'Request failed',
  });

  /// Full guard envelope `{ success, message, data }` after success check.
  Future<({Map<String, dynamic>? data, String? message})> postGuardEnvelope(
    String path, {
    Object? data,
    String fallbackMessage = 'Request failed',
  });

  Future<Map<String, dynamic>?> postMultipart(
    String path, {
    required FormData data,
    String fallbackMessage = 'Request failed',
  });

  /// Legacy `data/*` endpoints that return `{ resource: [...] }` without `success`.
  Future<dynamic> getRaw(String path, {Map<String, dynamic>? query});
}
