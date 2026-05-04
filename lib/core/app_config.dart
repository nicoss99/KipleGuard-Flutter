import 'app_flavor.dart';

/// Non-secret defaults; override with `--dart-define=...` (see Android `BaseConfig` / `RetrofitClient`).
abstract final class AppConfig {
  static String baseUrl(AppFlavor flavor) => switch (flavor) {
    AppFlavor.dev => const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://dev.api.kipleguard.local',
    ),
    AppFlavor.prod => const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.kipleguard.example',
    ),
  };

  /// Required for `X-Application-Key` header (native `BaseConfig.XAPPLICATIONKEY()`).
  static String xApplicationKey(AppFlavor flavor) => const String.fromEnvironment(
    'X_APPLICATION_KEY',
    defaultValue: '',
  );

  /// Web portal for forgot-password (`LoginActivity` → `BASE_WEB_URL#/auth/resetpassword`).
  static String webPortalBaseUrl(AppFlavor flavor) => const String.fromEnvironment(
    'WEB_PORTAL_URL',
    defaultValue: 'https://portal.kipleguard.example',
  );
}
