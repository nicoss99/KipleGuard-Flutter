import 'app_flavor.dart';

/// Compile-time tier from `--dart-define=API_ENV=dev|staging|prod`.
///
/// Matches [kipleHomev2]: `dev` / `development` / `staging` → staging APIs;
/// `prod` / `production` → production APIs. When empty, the entrypoint flavor wins.
const String kApiEnvDefine = String.fromEnvironment('API_ENV', defaultValue: '');

AppFlavor resolveEffectiveFlavor(AppFlavor entrypoint) {
  final d = kApiEnvDefine.trim().toLowerCase();
  if (d.isEmpty) return entrypoint;
  if (d == 'prod' || d == 'production') return AppFlavor.prod;
  if (d == 'dev' || d == 'development' || d == 'staging') {
    return AppFlavor.staging;
  }
  return entrypoint;
}
