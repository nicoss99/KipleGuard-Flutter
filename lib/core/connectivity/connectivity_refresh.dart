import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'network_connectivity.dart';

/// Whether the device currently has a network connection.
Future<bool> isDeviceOnline(Ref ref) =>
    ref.read(connectivityServiceProvider).checkOnline();

/// Refreshes [onBackOnline] when connectivity returns after being offline.
void listenConnectivityRefresh(WidgetRef ref, VoidCallback onBackOnline) {
  ref.listen<AsyncValue<bool>>(isOnlineProvider, (prev, next) {
    if (prev?.value == false && next.value == true) {
      onBackOnline();
    }
  });
}
