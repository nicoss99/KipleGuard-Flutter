import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_text_style.dart';

/// Single day chip in [AttendanceDayStrip].
class AttendanceDayCell extends StatelessWidget {
  const AttendanceDayCell({
    super.key,
    required this.width,
    required this.weekday,
    required this.day,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final double width;
  final String weekday;
  final String day;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColor.primary
        : isToday
        ? AppColor.primary.withValues(alpha: 0.45)
        : AppColor.greyBorder.withValues(alpha: 0.6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: width,
          decoration: BoxDecoration(
            color: selected ? AppColor.primary : AppColor.grey,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: borderColor,
              width: isToday && !selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.28),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday,
                style: AppTextStyle.bodyMuted.copyWith(
                  fontSize: 10.sp,
                  color: selected ? AppColor.white : AppColor.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                day,
                style: AppTextStyle.subtitle.copyWith(
                  fontSize: 17.sp,
                  color: selected ? AppColor.white : AppColor.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 3.h),
              if (isToday && !selected)
                Container(
                  width: 5.w,
                  height: 5.w,
                  decoration: const BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else
                SizedBox(height: 5.w),
            ],
          ),
        ),
      ),
    );
  }
}
