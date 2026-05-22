import 'package:go_router/go_router.dart';

import '../page/home/home_page.dart';
import '../page/register/register_gate_page.dart';
import '../page/register/register_id_scan_page.dart';
import '../page/register/register_visit_page.dart';
import '../page/register/register_visitor_details_page.dart';
import '../page/register/register_visitor_draft.dart';
import '../page/select_site/select_site_page.dart';
import '../page/unit_call/recent/call_recent_page.dart';
import '../page/unit_call/unit_call_page.dart';
import '../page/attendance/attendance_page.dart';
import '../page/booking/booking_detail_page.dart';
import '../page/booking/booking_page.dart';
import '../page/visitor/visitor_details_page.dart';
import '../page/visitor/visitor_page.dart';
import '../page/profile/change_password_page.dart';
import '../page/profile/edit_profile_page.dart';
import '../page/profile/profile_offline_page.dart';
import '../page/reporting/reporting_form_page.dart';
import '../page/reporting/reporting_gate_page.dart';
import '../page/reporting/reporting_models.dart';
import '../page/scan/scan_form_stub_page.dart';
import '../page/scan/scan_health_result_page.dart';
import '../page/scan/scan_qr_page.dart';
import 'app_route.dart';

List<RouteBase> buildHomeRoutes() => [
  GoRoute(
    path: AppRoute.home.path,
    name: AppRoute.home.name,
    builder: (context, state) => const HomePage(),
  ),
  GoRoute(
    path: AppRoute.selectSite.path,
    name: AppRoute.selectSite.name,
    builder: (context, state) => const SelectSitePage(),
  ),
  GoRoute(
    path: AppRoute.callUnits.path,
    name: AppRoute.callUnits.name,
    builder: (context, state) => const UnitCallPage(),
  ),
  GoRoute(
    path: AppRoute.callRecent.path,
    name: AppRoute.callRecent.name,
    builder: (context, state) => const CallRecentPage(),
  ),
  GoRoute(
    path: AppRoute.register.path,
    name: AppRoute.register.name,
    builder: (context, state) => const RegisterGatePage(),
  ),
  GoRoute(
    path: AppRoute.registerVisit.path,
    name: AppRoute.registerVisit.name,
    builder: (context, state) {
      final id = state.pathParameters['residenceUuid'] ?? '';
      return RegisterVisitPage(residenceUuid: id);
    },
  ),
  GoRoute(
    path: AppRoute.registerVisitorDetails.path,
    name: AppRoute.registerVisitorDetails.name,
    builder: (context, state) {
      final args = state.extra as RegisterVisitorDetailsArgs?;
      return RegisterVisitorDetailsPage(
        args:
            args ??
            const RegisterVisitorDetailsArgs(
              lprRequired: false,
              officeEnvironment: false,
            ),
      );
    },
  ),
  GoRoute(
    path: AppRoute.registerIdScan.path,
    name: AppRoute.registerIdScan.name,
    builder: (context, state) => const RegisterIdScanPage(),
  ),
  GoRoute(
    path: AppRoute.attendance.path,
    name: AppRoute.attendance.name,
    builder: (context, state) => const AttendancePage(),
  ),
  GoRoute(
    path: AppRoute.booking.path,
    name: AppRoute.booking.name,
    builder: (context, state) => const BookingPage(),
  ),
  GoRoute(
    path: AppRoute.bookingDetail.path,
    name: AppRoute.bookingDetail.name,
    builder: (context, state) {
      final id = state.pathParameters['bookingUuid'] ?? '';
      return BookingDetailPage(bookingUuid: id);
    },
  ),
  GoRoute(
    path: AppRoute.visitor.path,
    name: AppRoute.visitor.name,
    builder: (context, state) => const VisitorPage(),
  ),
  GoRoute(
    path: AppRoute.visitorDetails.path,
    name: AppRoute.visitorDetails.name,
    builder: (context, state) {
      final id = state.pathParameters['visitorUuid'] ?? '';
      return VisitorDetailsPage(visitorUuid: id);
    },
  ),
  GoRoute(
    path: AppRoute.reporting.path,
    name: AppRoute.reporting.name,
    builder: (context, state) => const ReportingGatePage(),
  ),
  GoRoute(
    path: AppRoute.reportingForm.path,
    name: AppRoute.reportingForm.name,
    builder: (context, state) {
      final args = state.extra as ReportingFormArgs?;
      if (args == null) return const ReportingGatePage();
      return ReportingFormPage(args: args);
    },
  ),
  GoRoute(
    path: AppRoute.scanQr.path,
    name: AppRoute.scanQr.name,
    builder: (context, state) => const ScanQrPage(),
  ),
  GoRoute(
    path: AppRoute.scanHealth.path,
    name: AppRoute.scanHealth.name,
    builder: (context, state) {
      final extra = state.extra;
      final map = extra is Map<String, dynamic>
          ? extra
          : extra is Map
              ? Map<String, dynamic>.from(extra)
              : <String, dynamic>{};
      return ScanHealthResultPage(payload: map);
    },
  ),
  GoRoute(
    path: AppRoute.scanForm.path,
    name: AppRoute.scanForm.name,
    builder: (context, state) {
      final id = state.pathParameters['formUuid'] ?? '';
      return ScanFormStubPage(applicationUuid: id);
    },
  ),
  GoRoute(
    path: AppRoute.editProfile.path,
    name: AppRoute.editProfile.name,
    builder: (context, state) => const EditProfilePage(),
  ),
  GoRoute(
    path: AppRoute.changePassword.path,
    name: AppRoute.changePassword.name,
    builder: (context, state) => const ChangePasswordPage(),
  ),
  GoRoute(
    path: AppRoute.profileOffline.path,
    name: AppRoute.profileOffline.name,
    builder: (context, state) => const ProfileOfflinePage(),
  ),
];
