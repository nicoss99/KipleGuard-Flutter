import 'package:go_router/go_router.dart';

import '../page/onboarding/onboarding_intro_page.dart';
import '../page/onboarding/onboarding_page.dart';
import 'app_route.dart';

List<RouteBase> buildOnboardingRoutes() => [
  GoRoute(
    path: AppRoute.onboardingIntro.path,
    name: AppRoute.onboardingIntro.name,
    builder: (context, state) => const OnboardingIntroPage(),
  ),
  GoRoute(
    path: AppRoute.onboarding.path,
    name: AppRoute.onboarding.name,
    builder: (context, state) => const OnboardingPage(),
  ),
];
