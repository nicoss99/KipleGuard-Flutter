import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';

/// List row — same pattern as [showLoginRegionSheet] options.
class ReportingSheetOption extends StatelessWidget {
  const ReportingSheetOption({
    super.key,
    required this.selected,
    required this.leading,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final Widget leading;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColor.primary.withValues(alpha: 0.08) : AppColor.grey.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? AppColor.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              leading,
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyle.subtitle.copyWith(
                    color: AppColor.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              if (selected) Icon(Icons.check_circle_rounded, color: AppColor.primary, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}
