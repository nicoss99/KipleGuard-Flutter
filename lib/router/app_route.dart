/// Typed route names and paths for [go_router].
enum AppRoute {
  home('/home', 'home'),
  login('/login', 'login'),
  onboardingIntro('/onboarding-intro', 'onboardingIntro'),
  onboarding('/onboarding', 'onboarding');

  const AppRoute(this.path, this.name);
  final String path;
  final String name;
}
