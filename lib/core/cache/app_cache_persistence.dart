import 'dart:async' show unawaited;

/// Handlers invoked when the app moves to background so caches are written to disk.
abstract final class AppCachePersistence {
  static final List<Future<void> Function()> _handlers = [];

  static void register(Future<void> Function() handler) {
    if (!_handlers.contains(handler)) _handlers.add(handler);
  }

  static void unregister(Future<void> Function() handler) {
    _handlers.remove(handler);
  }

  static Future<void> flushAll() async {
    final copy = List<Future<void> Function()>.from(_handlers);
    for (final handler in copy) {
      try {
        await handler();
      } catch (_) {}
    }
  }

  static void flushAllInBackground() {
    unawaited(flushAll());
  }
}
