import 'dart:developer' show log;

import 'package:permission_handler/permission_handler.dart';

/// Runtime prompts aligned with Android `AndroidManifest` guard / VoIP / camera flows.
/// Called once after the onboarding carousel completes (before login).
Future<void> requestPostOnboardingPermissions() async {
  try {
    final results = await [
      Permission.camera,
      Permission.microphone,
      Permission.phone,
    ].request();
    log('post-onboarding permissions: $results', name: 'PostOnboardingPermissions');
  } catch (e, st) {
    log(
      'permission request failed',
      name: 'PostOnboardingPermissions',
      error: e,
      stackTrace: st,
    );
  }
}
