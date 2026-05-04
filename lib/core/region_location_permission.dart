import 'dart:developer' show log;

import 'package:permission_handler/permission_handler.dart';

/// Prompts for location access when the user opens the region selector (list regions / geolocation context).
Future<void> requestLocationForRegionField() async {
  try {
    final status = await Permission.locationWhenInUse.request();
    log('region field location permission: $status', name: 'RegionLocation');
  } catch (e, st) {
    log(
      'location permission request failed',
      name: 'RegionLocation',
      error: e,
      stackTrace: st,
    );
  }
}
