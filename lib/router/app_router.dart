import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/auth_prefs.dart';
import '../core/onboarding_prefs.dart';
import 'app_route.dart';
import 'home_routes.dart';
import 'login_routes.dart';
import 'onboarding_routes.dart';

String _resolveInitialLocation() {
  if (!OnboardingPrefs.isCompleteSync) return AppRoute.onboardingIntro.path;
  if (!AuthPrefs.isLoggedInSync) return AppRoute.login.path;
  return AppRoute.home.path;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: _resolveInitialLocation(),
    redirect: (context, state) {
      final path = state.uri.path;
      final onboardingDone = OnboardingPrefs.isCompleteSync;
      final loggedIn = AuthPrefs.isLoggedInSync;

      if (!onboardingDone) {
        if (path == AppRoute.onboardingIntro.path ||
            path == AppRoute.onboarding.path) {
          return null;
        }
        return AppRoute.onboardingIntro.path;
      }

      if (onboardingDone && !loggedIn) {
        if (path == AppRoute.login.path) return null;
        if (path == AppRoute.onboardingIntro.path ||
            path == AppRoute.onboarding.path) {
          return AppRoute.login.path;
        }
        if (path == AppRoute.home.path ||
            path == AppRoute.selectSite.path ||
            path == AppRoute.callUnits.path ||
            path == AppRoute.callRecent.path ||
            path == AppRoute.register.path ||
            path.startsWith('${AppRoute.register.path}/') ||
            path == AppRoute.visitor.path ||
            path.startsWith('${AppRoute.visitor.path}/') ||
            path == AppRoute.attendance.path ||
            path == AppRoute.booking.path ||
            path.startsWith('${AppRoute.booking.path}/') ||
            path == AppRoute.reporting.path ||
            path == AppRoute.reportingForm.path ||
            path == AppRoute.scanQr.path ||
            path == AppRoute.scanHealth.path ||
            path.startsWith('/scan/form/')) {
          return AppRoute.login.path;
        }
        return AppRoute.login.path;
      }

      if (loggedIn) {
        if (path == AppRoute.login.path ||
            path == AppRoute.onboardingIntro.path ||
            path == AppRoute.onboarding.path) {
          return AppRoute.home.path;
        }
        return null;
      }

      return null;
    },
    routes: [
      ...buildOnboardingRoutes(),
      ...buildLoginRoutes(),
      ...buildHomeRoutes(),
    ],
  );
});
