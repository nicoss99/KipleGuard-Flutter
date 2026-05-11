import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';

/// Body-prefix app bar matching `SelectSitePage` / `CallRecentPage` — primary status strip + elevated white bar with animated title.
class RegisterStyledHeader extends StatelessWidget {
  const RegisterStyledHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: AppColor.primary,
          child: SizedBox(height: top, width: double.infinity),
        ),
        Material(
          color: AppColor.white,
          elevation: 2,
          shadowColor: AppColor.primary.withValues(alpha: 0.15),
          child: SizedBox(
            height: 52.h,
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColor.primary, size: 20.sp),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.06, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Text(
                      title,
                      key: ValueKey<String>(title),
                      textAlign: TextAlign.center,
                      style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                trailing ?? SizedBox(width: 48.w),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
