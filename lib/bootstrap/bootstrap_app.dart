import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/api_env.dart';
import '../core/app_flavor.dart';
import '../core/app_fresh_install.dart';
import '../core/auth_prefs.dart';
import '../core/onboarding_prefs.dart';
import '../l10n/app_l10n.dart';
import '../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widget/cache_lifecycle_host.dart';
import '../widget/offline_sync_host.dart';

Future<void> runKipleGuardApp({required AppFlavor flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppFreshInstall.ensureCleanFirstLaunch();
  await Future.wait([OnboardingPrefs.load(), AuthPrefs.load()]);
  final effective = resolveEffectiveFlavor(flavor);
  runApp(
    ProviderScope(
      overrides: [appFlavorProvider.overrideWithValue(effective)],
      child: KipleGuardApp(flavor: effective),
    ),
  );
}

class KipleGuardApp extends ConsumerWidget {
  const KipleGuardApp({super.key, required this.flavor});

  final AppFlavor flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: flavor == AppFlavor.prod ? 'KipleGuard' : 'KipleGuard (Staging)',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          builder: (ctx, routerChild) {
            appL10n = AppLocalizations.of(ctx);
            return CacheLifecycleHost(
              child: OfflineSyncHost(
                child: routerChild ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
