import 'bootstrap/bootstrap_app.dart';
import 'core/app_flavor.dart';

/// Same staging APIs as [main_dev]; prefer `lib/main_dev.dart` for build scripts.
Future<void> main() async {
  await runKipleGuardApp(flavor: AppFlavor.staging);
}
