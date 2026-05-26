import '../../l10n/app_l10n.dart';

/// Localized via [appL10n] — keys in `lib/l10n/app_en.arb`.
abstract final class ProfileStrings {
  static String get editProfile => appL10n.profileEditProfile;
  static String get signOut => appL10n.profileSignOut;
  static String get signOutConfirmationMessage => appL10n.profileSignOutConfirmationMessage;
  static String get cancel => appL10n.profileCancel;
  static String get account => appL10n.profileAccount;
  static String get name => appL10n.profileName;
  static String get changePassword => appL10n.profileChangePassword;
  static String get email => appL10n.profileEmail;
  static String get mobileNumber => appL10n.profileMobileNumber;
  static String get residences => appL10n.profileResidences;
  static String get helpSupport => appL10n.profileHelpSupport;
  static String get whatsNew => appL10n.profileWhatsNew;
  static String get offlineData => appL10n.profileOfflineData;
  static String get emptyOfflineData => appL10n.profileEmptyOfflineData;
  static String get profileUpdated => appL10n.profileProfileUpdated;
  static String get passwordUpdated => appL10n.profilePasswordUpdated;
  static String get signOutFailed => appL10n.profileSignOutFailed;
  static String get forceLogout => appL10n.profileForceLogout;
  static String get currentPassword => appL10n.profileCurrentPassword;
  static String get currentPasswordHint => appL10n.profileCurrentPasswordHint;
  static String get newPassword => appL10n.profileNewPassword;
  static String get newPasswordHint => appL10n.profileNewPasswordHint;
  static String get confirmPassword => appL10n.profileConfirmPassword;
  static String get confirmPasswordHint => appL10n.profileConfirmPasswordHint;
  static String get save => appL10n.profileSave;
  static String get passwordNotSame => appL10n.profilePasswordNotSame;
  static String get passwordEmpty => appL10n.profilePasswordEmpty;
  static String get currentPasswordRequired => appL10n.profileCurrentPasswordRequired;
}
