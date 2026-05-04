import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_assets.dart';
import '../../router/app_route.dart';
import '../../theme/app_color.dart';

/// Port of Android `OnboardingIntroActivity` (`pager_intro` + 1s delay → onboarding).
class OnboardingIntroPage extends StatefulWidget {
  const OnboardingIntroPage({super.key});

  @override
  State<OnboardingIntroPage> createState() => _OnboardingIntroPageState();
}

class _OnboardingIntroPageState extends State<OnboardingIntroPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer(const Duration(seconds: 1), () {
        if (!mounted) return;
        context.go(AppRoute.onboarding.path);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.primary, AppColor.primaryDark],
          ),
        ),
        child: Center(
          child: Image.asset(
            AppAssets.kipleGuardIcon,
            width: 200.w,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
