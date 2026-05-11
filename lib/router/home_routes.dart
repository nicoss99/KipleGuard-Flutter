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
import '../page/visitor/visitor_details_page.dart';
import '../page/visitor/visitor_page.dart';
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
        args: args ?? const RegisterVisitorDetailsArgs(lprRequired: false, officeEnvironment: false),
      );
    },
  ),
  GoRoute(
    path: AppRoute.registerIdScan.path,
    name: AppRoute.registerIdScan.name,
    builder: (context, state) => const RegisterIdScanPage(),
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
];
