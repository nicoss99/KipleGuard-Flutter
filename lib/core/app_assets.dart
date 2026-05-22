/// Central asset paths (brand, illustrations).
abstract final class AppAssets {
  /// From Android `res/drawable/ic_splash_logo.png` (KipleGuard / kipleSafe branding).
  static const kipleGuardIcon = 'assets/images/kiple_guard_icon.png';

  // --- Dashboard module grid (`assets/images/dashboard/*.png`) ---
  static const icDashboardAttendance = 'assets/images/dashboard/ic_dashboard_attendance.png';
  static const icDashboardAttendanceGrey = 'assets/images/dashboard/ic_dashboard_attendance_grey.png';
  static const icDashboardVisitor = 'assets/images/dashboard/ic_dashboard_visitor.png';
  static const icDashboardVisitorGrey = 'assets/images/dashboard/ic_dashboard_visitor_grey.png';
  static const icDashboardBooking = 'assets/images/dashboard/ic_dashboard_booking.png';
  static const icDashboardBookingGrey = 'assets/images/dashboard/ic_dashboard_booking_grey.png';
  static const icDashboardReporting = 'assets/images/dashboard/ic_dashboard_reporting.png';
  static const icDashboardReportingGrey = 'assets/images/dashboard/ic_dashboard_reporting_grey.png';

  // --- Home bottom bar (`assets/home_vectors/*.svg`) ---
  static const icDashboardCall = 'assets/home_vectors/ic_dashboard_call.svg';
  static const icDashboardCallBlue = 'assets/home_vectors/ic_dashboard_call_blue.svg';
  static const icDashboardAddUser = 'assets/home_vectors/ic_dashboard_add_user.svg';
  static const icDashboardQrBlue = 'assets/home_vectors/ic_dashboard_qr_blue.svg';

  /// Attendance record list check-in / check-out.
  static const icVisitorCheckin = 'assets/home_vectors/ic_visitor_checkin.svg';
  static const icVisitorCheckout = 'assets/home_vectors/ic_visitor_checkout.svg';
}
