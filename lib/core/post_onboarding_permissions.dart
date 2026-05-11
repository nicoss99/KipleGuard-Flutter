import 'package:permission_handler/permission_handler.dart';

import 'app_logger.dart';

/// Runtime prompts aligned with Android `AndroidManifest` guard / VoIP / camera flows.
/// Called once after the onboarding carousel completes (before login).
Future<void> requestPostOnboardingPermissions() async {
  try {
    final results = await [
      Permission.camera,
      Permission.microphone,
      Permission.phone,
    ].request();
    AppLog.info('post-onboarding permissions: $results', tag: 'PostOnboardingPermissions');
  } catch (e, st) {
    AppLog.error(
      'permission request failed',
      tag: 'PostOnboardingPermissions',
      error: e,
      stackTrace: st,
    );
  }
}
