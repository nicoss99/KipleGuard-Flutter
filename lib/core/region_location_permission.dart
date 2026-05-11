import 'package:permission_handler/permission_handler.dart';

import 'app_logger.dart';

/// Prompts for location access when the user opens the region selector (list regions / geolocation context).
Future<void> requestLocationForRegionField() async {
  try {
    final status = await Permission.locationWhenInUse.request();
    AppLog.info('region field location permission: $status', tag: 'RegionLocation');
  } catch (e, st) {
    AppLog.error(
      'location permission request failed',
      tag: 'RegionLocation',
      error: e,
      stackTrace: st,
    );
  }
}
