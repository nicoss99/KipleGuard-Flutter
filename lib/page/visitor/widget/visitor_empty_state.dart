import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../visitor_strings.dart';

class VisitorEmptyState extends StatelessWidget {
  const VisitorEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Material(
        color: AppColor.white,
        elevation: 1,
        shadowColor: AppColor.textPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline_rounded, size: 48.sp, color: AppColor.textSecondary),
              SizedBox(height: 12.h),
              Text(VisitorStrings.empty, style: AppTextStyle.bodyMuted, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
