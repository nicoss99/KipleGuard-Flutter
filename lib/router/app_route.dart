/// Typed route names and paths for [go_router].
enum AppRoute {
  home('/home', 'home'),
  selectSite('/select-site', 'selectSite'),
  callUnits('/call-units', 'callUnits'),
  callRecent('/call-recent', 'callRecent'),
  register('/register', 'register'),
  registerVisit('/register/visit/:residenceUuid', 'registerVisit'),
  registerVisitorDetails('/register/visitor-details', 'registerVisitorDetails'),
  registerIdScan('/register/id-scan', 'registerIdScan'),
  visitor('/visitor', 'visitor'),
  visitorDetails('/visitor/:visitorUuid', 'visitorDetails'),
  attendance('/attendance', 'attendance'),
  booking('/booking', 'booking'),
  bookingDetail('/booking/:bookingUuid', 'bookingDetail'),
  reporting('/reporting', 'reporting'),
  reportingForm('/reporting/form', 'reportingForm'),
  scanQr('/scan', 'scanQr'),
  scanHealth('/scan/health', 'scanHealth'),
  scanForm('/scan/form/:formUuid', 'scanForm'),
  login('/login', 'login'),
  onboardingIntro('/onboarding-intro', 'onboardingIntro'),
  onboarding('/onboarding', 'onboarding');

  const AppRoute(this.path, this.name);
  final String path;
  final String name;
}

/// Full paths with segments (not covered by [AppRoute.path] templates).
abstract final class AppPaths {
  static String registerVisit(String residenceUuid) =>
      '/register/visit/$residenceUuid';

  static String visitorDetails(String visitorUuid) => '/visitor/$visitorUuid';

  static String bookingDetail(String bookingUuid) => '/booking/$bookingUuid';

  static String scanForm(String formUuid) => '/scan/form/$formUuid';
}
