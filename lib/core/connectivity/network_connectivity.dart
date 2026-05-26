import 'dart:async' show StreamController, StreamSubscription, unawaited;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final connectivityServiceProvider = Provider<NetworkConnectivity>(
  (ref) => NetworkConnectivity(Connectivity()),
);

final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onlineStream;
});

/// Observes device connectivity (Wi‑Fi / mobile / ethernet).
final class NetworkConnectivity {
  NetworkConnectivity(this._connectivity);

  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _started = false;

  Stream<bool> get onlineStream {
    _ensureStarted();
    return _controller.stream;
  }

  Future<bool> checkOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  void _ensureStarted() {
    if (_started) return;
    _started = true;
    unawaited(_emitCurrent());
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _controller.add(_isOnline(results));
    });
  }

  Future<void> _emitCurrent() async {
    _controller.add(await checkOnline());
  }

  bool _isOnline(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
