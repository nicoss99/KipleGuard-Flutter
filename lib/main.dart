import 'bootstrap/bootstrap_app.dart';
import 'core/app_flavor.dart';

/// Default IDE entry; use [main_dev] (staging) or [main_prod] (production) for builds.
Future<void> main() async {
  await runKipleGuardApp(flavor: AppFlavor.prod);
}
