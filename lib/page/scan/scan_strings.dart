import '../../l10n/app_l10n.dart';

/// Localized via [appL10n] — keys in `lib/l10n/app_en.arb`.
abstract final class ScanStrings {
  static String get scanQrCode => appL10n.scanScanQrCode;
  static String get scanAlignHint => appL10n.scanScanAlignHint;
  static String get scanFromGallery => appL10n.scanScanFromGallery;
  static String get noQrInImage => appL10n.scanNoQrInImage;
  static String get unableScanQr => appL10n.scanUnableScanQr;
  static String get qrNotBelong => appL10n.scanQrNotBelong;
  static String get qrNotBelong2 => appL10n.scanQrNotBelong2;
  static String get applicationTitle => appL10n.scanApplicationTitle;
}
