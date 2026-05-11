import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';

class RegisterBuildingTile extends StatelessWidget {
  const RegisterBuildingTile({super.key, required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.grey,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14.h),
          child: Row(
            children: [
              Expanded(child: Text(name, style: AppTextStyle.subtitle)),
              Icon(Icons.chevron_right, color: AppColor.textSecondary, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}
