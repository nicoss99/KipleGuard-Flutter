import 'dart:convert';

import 'package:dio/dio.dart';

/// Formats Dio request/response bodies for [AppLog] (truncates large payloads).
abstract final class ApiLogFormat {
  static const maxBodyChars = 8000;

  static String request(RequestOptions o) {
    final b = StringBuffer()
      ..writeln('→ ${o.method} ${o.uri}')
      ..writeln('headers: ${_headers(o.headers)}');
    if (o.queryParameters.isNotEmpty) {
      b.writeln('query: ${o.queryParameters}');
    }
    final body = _body(o.data);
    if (body != null) b.writeln('body: $body');
    return b.toString().trimRight();
  }

  static String response(Response<dynamic> r) {
    final b = StringBuffer()
      ..writeln('← ${r.statusCode} ${r.requestOptions.method} ${r.requestOptions.uri}')
      ..writeln('headers: ${_headers(r.headers.map)}');
    final body = _body(r.data);
    if (body != null) b.writeln('body: $body');
    return b.toString().trimRight();
  }

  static String error(DioException e) {
    final b = StringBuffer()
      ..writeln('✕ ${e.type.name} ${e.requestOptions.method} ${e.requestOptions.uri}');
    if (e.response?.statusCode != null) {
      b.writeln('status: ${e.response!.statusCode}');
    }
    if (e.message != null) b.writeln('message: ${e.message}');
    final body = _body(e.response?.data);
    if (body != null) b.writeln('body: $body');
    return b.toString().trimRight();
  }

  static Map<String, dynamic> _headers(Map<String, dynamic> raw) {
    final out = <String, dynamic>{};
    raw.forEach((k, v) {
      final key = k.toString();
      if (key.toLowerCase() == 'authorization') {
        out[key] = _redactAuth(v?.toString() ?? '');
      } else {
        out[key] = v;
      }
    });
    return out;
  }

  static String _redactAuth(String value) {
    if (value.isEmpty) return value;
    if (value.length <= 12) return '***';
    return '${value.substring(0, 7)}…***';
  }

  static String? _body(dynamic data) {
    if (data == null) return null;
    String text;
    if (data is String) {
      text = data;
    } else if (data is List<int>) {
      text = '<${data.length} bytes>';
    } else {
      try {
        text = const JsonEncoder.withIndent('  ').convert(data);
      } catch (_) {
        text = data.toString();
      }
    }
    if (text.length <= maxBodyChars) return text;
    return '${text.substring(0, maxBodyChars)}\n… [truncated ${text.length - maxBodyChars} chars]';
  }
}
