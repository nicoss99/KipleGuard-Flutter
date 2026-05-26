import '../../l10n/app_l10n.dart';

/// Localized login copy — keys in `lib/l10n/app_en.arb`.
abstract final class LoginStrings {
  static String get signInFailedTitle => appL10n.loginSignInFailedTitle;
  static String get invalidCredentials => appL10n.loginInvalidCredentials;
  static String get emailOrPhoneLabel => appL10n.loginEmailOrPhoneLabel;
  static String get emailOrPhoneHint => appL10n.loginEmailOrPhoneHint;
  static String get passwordLabel => appL10n.loginPasswordLabel;
  static String get passwordHint => appL10n.loginPasswordHint;
  static String get forgotPassword => appL10n.loginForgotPassword;
  static String get signIn => appL10n.loginSignIn;
  static String get switchDeviceTitle => appL10n.loginSwitchDeviceTitle;
  static String get switchDeviceProceed => appL10n.loginSwitchDeviceProceed;
  static String get regionPlaceholder => appL10n.loginRegionPlaceholder;
  static String get regionSheetTitle => appL10n.loginRegionSheetTitle;
  static String get regionSheetSubtitle => appL10n.loginRegionSheetSubtitle;
  static String get regionMalaysia => appL10n.loginRegionMalaysia;
  static String get regionIndonesia => appL10n.loginRegionIndonesia;
  static String get regionVietnam => appL10n.loginRegionVietnam;
}
