import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/onboarding_prefs.dart';
import '../../core/post_onboarding_permissions.dart';
import '../../router/app_route.dart';
import '../../theme/app_color.dart';
import 'onboarding_slide_data.dart';
import 'widget/onboarding_controls_bar.dart';
import 'widget/onboarding_slide_view.dart';

/// Port of Android `OnboardingActivity` + `SlidingImageAdapter` (4 slides).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;
  final _slides = OnboardingSlides.all;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goNext(BuildContext context) async {
    if (_index >= _slides.length - 1) {
      final fromProfile = GoRouterState.of(context).uri.queryParameters['from'] == 'profile';
      if (fromProfile) {
        if (!context.mounted) return;
        context.pop();
        if (context.mounted) context.pop();
        return;
      }
      await requestPostOnboardingPermissions();
      if (!context.mounted) return;
      await OnboardingPrefs.setComplete();
      if (!context.mounted) return;
      context.go(AppRoute.login.path);
      return;
    }
    _controller.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  void _goPrev() {
    if (_index <= 0) return;
    _controller.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => OnboardingSlideView(data: _slides[i]),
              ),
            ),
            OnboardingControlsBar(
              pageIndex: _index,
              pageCount: _slides.length,
              onPrev: _goPrev,
              onNext: () => _goNext(context),
            ),
          ],
        ),
      ),
    );
  }
}
