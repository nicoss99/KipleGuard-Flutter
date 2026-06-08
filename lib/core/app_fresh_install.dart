import 'package:shared_preferences/shared_preferences.dart';

import 'app_logger.dart';
import 'cache/app_cache_store.dart';

/// Ensures a clean slate on the very first launch after install.
abstract final class AppFreshInstall {
  static const installMarkerKey = 'kiple_app_install_marker_v1';

  /// Clears restored/stale local state once per install, before prefs are loaded.
  static Future<void> ensureCleanFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(installMarkerKey) == true) return;

    AppLog.info('First launch — clearing local data and cache', tag: 'AppFreshInstall');
    await AppCacheStore.clearAll();
    await prefs.setBool(installMarkerKey, true);
  }
}
