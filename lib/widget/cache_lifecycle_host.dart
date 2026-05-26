import 'package:flutter/widgets.dart';

import '../core/cache/app_cache_persistence.dart';

/// Persists registered offline caches when the app is backgrounded or closed.
class CacheLifecycleHost extends StatefulWidget {
  const CacheLifecycleHost({super.key, required this.child});

  final Widget child;

  @override
  State<CacheLifecycleHost> createState() => _CacheLifecycleHostState();
}

class _CacheLifecycleHostState extends State<CacheLifecycleHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppCachePersistence.flushAllInBackground();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        AppCachePersistence.flushAllInBackground();
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
