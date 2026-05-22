import 'bootstrap/bootstrap_app.dart';
import 'core/app_flavor.dart';

/// Staging entrypoint (same role as [kipleHomev2] `lib/main_dev.dart`).
Future<void> main() async {
  await runKipleGuardApp(flavor: AppFlavor.staging);
}
