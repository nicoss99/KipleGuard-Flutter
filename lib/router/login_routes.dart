import 'package:go_router/go_router.dart';

import '../page/login/login_page.dart';
import 'app_route.dart';

List<RouteBase> buildLoginRoutes() => [
  GoRoute(
    path: AppRoute.login.path,
    name: AppRoute.login.name,
    builder: (context, state) => const LoginPage(),
  ),
];
