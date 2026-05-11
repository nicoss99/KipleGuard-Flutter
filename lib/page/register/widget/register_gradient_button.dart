import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';

/// Android `button_background_rounded.xml` — horizontal gradient, 10dp corners, white label.
class RegisterGradientButton extends StatelessWidget {
  const RegisterGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.margin,
  });

  final String label;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.all(20.w),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColor.primaryDark, AppColor.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10.r),
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Center(
                child: Text(
                  label,
                  style: AppTextStyle.subtitle.copyWith(color: AppColor.onPrimary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
