import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../login_strings.dart';

/// Sign-in CTA — white background, primary label (kipleHomev2 login form).
class LoginSignInButton extends StatelessWidget {
  const LoginSignInButton({
    super.key,
    required this.onPressed,
    required this.enabled,
    this.absorbing = false,
    this.label,
  });

  final VoidCallback onPressed;
  final bool enabled;
  final bool absorbing;
  final String? label;

  static ButtonStyle _style() => FilledButton.styleFrom(
        backgroundColor: AppColor.white,
        foregroundColor: AppColor.primary,
        disabledBackgroundColor: AppColor.white,
        disabledForegroundColor: AppColor.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      );

  TextStyle _labelStyle() => AppTextStyle.subtitle.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16.sp,
        color: AppColor.primary,
        height: 1.2,
      );

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: absorbing || !enabled,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: _style(),
          child: Text(label ?? LoginStrings.signIn, style: _labelStyle()),
        ),
      ),
    );
  }
}
