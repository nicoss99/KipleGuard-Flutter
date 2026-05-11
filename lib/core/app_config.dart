import 'app_flavor.dart';

/// URL and key defaults aligned with Android JNI `BaseConfig` (`keys.c`).
/// Override at build time: `--dart-define=API_BASE_URL=...`, `X_APPLICATION_KEY=...`, etc.
abstract final class AppConfig {
  // --- XAPPKEY (JNI: `Java_..._BaseConfig_XAPPLICATIONKEY`) ---
  static const _kXApplicationKey =
      '5Syw49JVgmCDrGv5QBDbxtDvpTR2XxkF36Vr4EMVkvDVecJX';

  // --- BASEURL (JNI: `DEVBASEURL`, `STAGBASEURLK8S`, `PRODBASEURL*`) ---
  static const _kDevBaseUrl = 'https://api-dev.dhome.io/v1.0/';
  static const _kStgK8sBaseUrl = 'https://k8s-stg-api.kiplelive.com/';
  static const _kProdInBaseUrl = 'https://api-in.kiplelive.com/';
  static const _kProdVnBaseUrl = 'https://api-vn.kiplelive.com/';
  static const _kProdK8sBaseUrl = 'https://k8s-api.kiplelive.com/';

  // --- PORTAL (JNI: `DEVPORTAL`, `STAGPORTALK8S`, `PRODPORTAL*`) ---
  static const _kDevPortal = 'https://admin-dev.dhome.io/';
  static const _kStgPortalK8s = 'https://k8s-stg-admin.kiplelive.com/';
  static const _kProdPortalIn = 'https://admin-in.kiplelive.com/';
  static const _kProdPortalVn = 'https://admin-vn.kiplelive.com/';
  static const _kProdPortalK8s = 'https://k8s-admin.kiplelive.com/';

  // --- FR (JNI: `DEVFR`, `STAGFRK8S`, `PRODFR*`) ---
  static const _kDevFr = 'http://dev-fr.dhome.io';
  static const _kStgFrK8s = 'https://k8s-stg-fr.kiplelive.com/';
  static const _kProdFrIn = 'https://fr-in.kiplelive.com/';
  static const _kProdFrVn = 'https://fr-vn.kiplelive.com/';
  static const _kProdFrK8s = 'https://k8s-fr.kiplelive.com/';

  // --- E-PASS (JNI: `DEVEPASS`, `STAGEPASSK8S`, `PRODEPASS*`) ---
  static const _kDevEpass = 'https://dev-visitor.dhome.io/epass';
  static const _kStgEpassK8s = 'https://k8s-stg-visitor.kiplelive.com/epass';
  static const _kProdEpassIn = 'https://visitor-in.kiplelive.com/epass';
  static const _kProdEpassVn = 'https://visitor-vn.kiplelive.com/epass';
  static const _kProdEpassK8s = 'https://k8s-visitor.kiplelive.com/epass';

  // --- TWILIO (JNI: `PRODTWILIOURL`, `PRODTWILIOPUSHSID`) ---
  static const _kProdTwilioUrl = 'https://voip.kiplelive.com/';
  static const _kProdTwilioPushSid = 'CR7b2fabb61b0d1b4ff840b051ad3d080e';

  /// Android `RetrofitListAPI.sessionAPI` — JSON body: `{ "identifier", "challenge" }`.
  static const sessionApiPath = 'admin/session';

  /// `POST data/user_firebase_tokens` (after session).
  static const userFirebaseTokensPath = 'data/user_firebase_tokens';

  static String baseUrl(AppFlavor flavor) => switch (flavor) {
    AppFlavor.dev => const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: _kDevBaseUrl,
    ),
    AppFlavor.staging => const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: _kStgK8sBaseUrl,
    ),
    AppFlavor.prod => const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: _kProdK8sBaseUrl,
    ),
  };

  /// Required for `X-Application-Key` (same value for all flavors in JNI).
  static String xApplicationKey(AppFlavor _) => const String.fromEnvironment(
    'X_APPLICATION_KEY',
    defaultValue: _kXApplicationKey,
  );

  static String webPortalBaseUrl(AppFlavor flavor) => switch (flavor) {
    AppFlavor.dev => const String.fromEnvironment(
      'WEB_PORTAL_URL',
      defaultValue: _kDevPortal,
    ),
    AppFlavor.staging => const String.fromEnvironment(
      'WEB_PORTAL_URL',
      defaultValue: _kStgPortalK8s,
    ),
    AppFlavor.prod => const String.fromEnvironment(
      'WEB_PORTAL_URL',
      defaultValue: _kProdPortalK8s,
    ),
  };

  /// Face-recognition / FR web base (JNI `DEVFR`, `STAGFRK8S`, `PRODFRK8S`).
  static String frBaseUrl(AppFlavor flavor) => switch (flavor) {
    AppFlavor.dev =>
      const String.fromEnvironment('FR_BASE_URL', defaultValue: _kDevFr),
    AppFlavor.staging => const String.fromEnvironment(
      'FR_BASE_URL',
      defaultValue: _kStgFrK8s,
    ),
    AppFlavor.prod => const String.fromEnvironment(
      'FR_BASE_URL',
      defaultValue: _kProdFrK8s,
    ),
  };

  /// E-pass visitor base URL path (JNI `DEVEPASS`, `STAGEPASSK8S`, `PRODEPASSK8S`).
  static String epassBaseUrl(AppFlavor flavor) => switch (flavor) {
    AppFlavor.dev =>
      const String.fromEnvironment('EPASS_BASE_URL', defaultValue: _kDevEpass),
    AppFlavor.staging => const String.fromEnvironment(
      'EPASS_BASE_URL',
      defaultValue: _kStgEpassK8s,
    ),
    AppFlavor.prod => const String.fromEnvironment(
      'EPASS_BASE_URL',
      defaultValue: _kProdEpassK8s,
    ),
  };

  static String twilioVoipBaseUrl() => const String.fromEnvironment(
    'TWILIO_VOIP_URL',
    defaultValue: _kProdTwilioUrl,
  );

  static String twilioPushCredentialSid() => const String.fromEnvironment(
    'TWILIO_PUSH_SID',
    defaultValue: _kProdTwilioPushSid,
  );

  // --- Prod IN/VN/K8S reference URLs (JNI parity; default prod flavor uses K8s — override via dart-define) ---
  static String get prodApiBaseUrlIn => _kProdInBaseUrl;
  static String get prodApiBaseUrlVn => _kProdVnBaseUrl;
  static String get prodApiBaseUrlK8s => _kProdK8sBaseUrl;
  static String get prodWebPortalIn => _kProdPortalIn;
  static String get prodWebPortalVn => _kProdPortalVn;
  static String get prodWebPortalK8s => _kProdPortalK8s;
  static String get prodFrIn => _kProdFrIn;
  static String get prodFrVn => _kProdFrVn;
  static String get prodFrK8s => _kProdFrK8s;
  static String get prodEpassIn => _kProdEpassIn;
  static String get prodEpassVn => _kProdEpassVn;
  static String get prodEpassK8s => _kProdEpassK8s;
}
