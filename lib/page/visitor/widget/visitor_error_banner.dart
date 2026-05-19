import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';

class VisitorErrorBanner extends StatelessWidget {
  const VisitorErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 8.h, AppSpacing.md, 0),
      child: Material(
        color: AppColor.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColor.orange, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(child: Text(message, style: AppTextStyle.body)),
            ],
          ),
        ),
      ),
    );
  }
}
