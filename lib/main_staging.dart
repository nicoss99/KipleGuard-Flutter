import 'bootstrap/bootstrap_app.dart';
import 'core/app_flavor.dart';

/// Android `stag_k8s` → [BaseConfig.STAGBASEURLK8S] / [BaseConfig.STAGPORTALK8S] (`jni/keys.c`).
Future<void> main() async {
  await runKipleGuardApp(flavor: AppFlavor.staging);
}
