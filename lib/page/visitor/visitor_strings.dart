import '../../l10n/app_l10n.dart';

/// Localized via [appL10n] — keys in `lib/l10n/app_en.arb`.
abstract final class VisitorStrings {
  static String get title => appL10n.visitorTitle;
  static String get pelawat => appL10n.visitorPelawat;
  static String get tabCheckIn => appL10n.visitorTabCheckIn;
  static String get tabIncoming => appL10n.visitorTabIncoming;
  static String get tabOvertime => appL10n.visitorTabOvertime;
  static String get searchHint => appL10n.visitorSearchHint;
  static String get empty => appL10n.visitorEmpty;
  static String get loadError => appL10n.visitorLoadError;
  static String get register => appL10n.visitorRegister;
  static String get detailsTitle => appL10n.visitorDetailsTitle;
  static String get checkIn => appL10n.visitorCheckIn;
  static String get checkOut => appL10n.visitorCheckOut;
  static String get checkInSuccess => appL10n.visitorCheckInSuccess;
  static String get checkOutSuccess => appL10n.visitorCheckOutSuccess;
  static String get save => appL10n.visitorSave;
  static String get updated => appL10n.visitorUpdated;
  static String get qrRequired => appL10n.visitorQrRequired;
  static String get parkingLot => appL10n.visitorParkingLot;
  static String get visitorFrom => appL10n.visitorVisitorFrom;
}
