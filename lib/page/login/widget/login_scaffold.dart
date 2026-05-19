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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(50.w, 24.h, 50.w, 24.h),
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
      ),
    );
  }

  static double get _fieldFontSize => 15.sp;
  static double get _hintFontSize => 12.sp;

  /// Height of one-line login inputs (text row + vertical padding).
  static double oneLineFieldHeight(BuildContext context) {
    final line = _fieldFontSize * 1.3;
    final padV = 14.h * 2;
    return math.max(kMinInteractiveDimension, padV + line);
  }

  static TextStyle fieldTextStyle(BuildContext context, {bool active = false}) =>
      LoginTheme.fieldText(context).copyWith(
        fontSize: _fieldFontSize,
        height: 1.25,
        color: AppColor.white,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
      );

  static TextStyle fieldHintStyle(BuildContext context, {bool active = false}) =>
      LoginTheme.fieldText(context).copyWith(
        fontSize: _hintFontSize,
        height: 1.2,
        color: AppColor.white.withValues(alpha: active ? 0.7 : 0.5),
        fontWeight: FontWeight.w400,
      );
}
