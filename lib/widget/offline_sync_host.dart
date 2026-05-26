import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/connectivity/network_connectivity.dart';
import '../page/reporting/reporting_sync_service.dart';

/// Syncs queued incidents when connectivity returns.
class OfflineSyncHost extends ConsumerStatefulWidget {
  const OfflineSyncHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OfflineSyncHost> createState() => _OfflineSyncHostState();
}

class _OfflineSyncHostState extends ConsumerState<OfflineSyncHost> {
  bool? _wasOnline;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(isOnlineProvider, (prev, next) {
      final online = next.value;
      if (online != true) {
        _wasOnline = online;
        return;
      }
      if (_wasOnline == false) {
        unawaited(ref.read(reportingSyncServiceProvider).processQueue());
      }
      _wasOnline = true;
    });
    return widget.child;
  }
}
