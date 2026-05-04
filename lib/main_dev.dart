import 'bootstrap/bootstrap_app.dart';
import 'core/app_flavor.dart';

Future<void> main() async {
  await runKipleGuardApp(flavor: AppFlavor.dev);
}
