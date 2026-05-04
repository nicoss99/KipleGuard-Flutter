import 'package:go_router/go_router.dart';

import '../page/home/home_page.dart';
import 'app_route.dart';

List<RouteBase> buildHomeRoutes() => [
  GoRoute(
    path: AppRoute.home.path,
    name: AppRoute.home.name,
    builder: (context, state) => const HomePage(),
  ),
];
