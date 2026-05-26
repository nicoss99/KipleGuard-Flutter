import '../../l10n/app_l10n.dart';

/// Localized via [appL10n] — keys in `lib/l10n/app_en.arb`.
abstract final class DashboardStrings {
  static String get appTitle => appL10n.dashboardAppTitle;
  static String get viewQr => appL10n.dashboardViewQr;
  static String get attendance => appL10n.dashboardAttendance;
  static String get kehadiran => appL10n.dashboardKehadiran;
  static String get visitor => appL10n.dashboardVisitor;
  static String get pelawat => appL10n.dashboardPelawat;
  static String get booking => appL10n.dashboardBooking;
  static String get tempahan => appL10n.dashboardTempahan;
  static String get reporting => appL10n.dashboardReporting;
  static String get laporan => appL10n.dashboardLaporan;
  static String get call => appL10n.dashboardCall;
  static String get register => appL10n.dashboardRegister;
  static String get scanQr => appL10n.dashboardScanQr;
  static String get welcomeUser => appL10n.dashboardWelcomeUser;
  static String get noRolesAuthorized => appL10n.dashboardNoRolesAuthorized;
  static String get featureAttendance => appL10n.dashboardFeatureAttendance;
  static String get featureVisitor => appL10n.dashboardFeatureVisitor;
  static String get featureReport => appL10n.dashboardFeatureReport;
  static String get featureBooking => appL10n.dashboardFeatureBooking;
  static String get featureCall => appL10n.dashboardFeatureCall;
}
