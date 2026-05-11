import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../register_strings.dart';

/// Android `button_rounded_blue_border` — 2dp primary outline, 10dp corners, primary label.
class RegisterAddVisitorButton extends StatelessWidget {
  const RegisterAddVisitorButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColor.primary, width: 2),
          ),
          padding: EdgeInsets.symmetric(vertical: 18.h),
          alignment: Alignment.center,
          child: Text(
            RegisterStrings.addVisitorButton,
            style: AppTextStyle.subtitle.copyWith(
              color: AppColor.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
