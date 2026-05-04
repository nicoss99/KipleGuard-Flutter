import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_assets.dart';
import '../../../theme/app_color.dart';
import '../login_theme.dart';

/// Full-viewport blue background (reference: solid #0091EA with slight depth).
class LoginScaffold extends StatelessWidget {
  const LoginScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: AppColor.loginScreenBlue,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.loginScreenBlue, AppColor.loginScreenBlueDeep],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            50.w,
            pad.top + 24.h,
            50.w,
            pad.bottom + 24.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12.h),
              Image.asset(
                AppAssets.kipleGuardIcon,
                height: 150.h,
                fit: BoxFit.contain,
                color: AppColor.white,
                colorBlendMode: BlendMode.srcATop,
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Height of one-line login inputs using [fieldDecoration] (matches [TextField] + suffix icon row).
  static double oneLineFieldHeight(BuildContext context) {
    final style = LoginTheme.fieldText(context);
    final fontSize = style.fontSize ?? 16.sp;
    final line = fontSize * 1.25;
    final padV = 18.h * 2;
    return math.max(kMinInteractiveDimension, padV + line);
  }

  static InputDecoration fieldDecoration(
    BuildContext context, {
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        hintStyle: LoginTheme.fieldText(context).copyWith(
          color: AppColor.white.withValues(alpha: 0.65),
        ),
        filled: true,
        fillColor: AppColor.white.withValues(alpha: 0.15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColor.white.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColor.white),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 18.h),
        suffixIcon: suffixIcon,
      );
}
