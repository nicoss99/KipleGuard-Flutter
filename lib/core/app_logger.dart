import 'dart:developer' as developer;

/// App-wide logging via [developer.log] (not [print]) — filter in DevTools by [name] / level.
///
/// Use [track] for flow / product events; use [debug]–[error] for diagnostics.
abstract final class AppLog {
  static const _defaultName = 'KipleGuard';

  // Level: see `dart:developer` — FINE=500, INFO=800, WARNING=900, SEVERE=1000
  static const int _fine = 500;
  static const int _info = 800;
  static const int _warning = 900;
  static const int _severe = 1000;

  static void debug(String message, {String? tag, Map<String, Object?>? data}) {
    _emit(_fine, message, tag: tag, data: data);
  }

  static void info(String message, {String? tag, Map<String, Object?>? data}) {
    _emit(_info, message, tag: tag, data: data);
  }

  static void warning(
    String message, {
    String? tag,
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _emit(
      _warning,
      message,
      tag: tag,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(
    String message, {
    String? tag,
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _emit(
      _severe,
      message,
      tag: tag,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// High-level event for debugging / analytics-style tracking (screen, action, attributes).
  static void track(
    String event, {
    String? screen,
    Map<String, Object?>? attributes,
  }) {
    final buffer = StringBuffer('[track] $event');
    if (screen != null) buffer.write(' | screen=$screen');
    if (attributes != null && attributes.isNotEmpty) {
      buffer.write(' | $attributes');
    }
    _emit(_info, buffer.toString(), tag: 'KipleGuard.Track');
  }

  static void _emit(
    int level,
    String message, {
    String? tag,
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final line = (data != null && data.isNotEmpty) ? '$message | $data' : message;
    developer.log(
      line,
      name: tag ?? _defaultName,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
