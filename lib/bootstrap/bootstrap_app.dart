import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/app_flavor.dart';
import '../core/auth_prefs.dart';
import '../core/onboarding_prefs.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

Future<void> runKipleGuardApp({required AppFlavor flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([OnboardingPrefs.load(), AuthPrefs.load()]);
  runApp(
    ProviderScope(
      overrides: [appFlavorProvider.overrideWithValue(flavor)],
      child: const KipleGuardApp(),
    ),
  );
}

class KipleGuardApp extends ConsumerWidget {
  const KipleGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'KipleGuard',
          theme: AppTheme.light(),
          routerConfig: router,
        );
      },
    );
  }
}
