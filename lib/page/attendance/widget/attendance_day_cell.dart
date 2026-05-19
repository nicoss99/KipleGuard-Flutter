import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_text_style.dart';

/// Android `v2_adapter_calendar_day.xml` — day number chip (50dp).
class AttendanceDayCell extends StatelessWidget {
  const AttendanceDayCell({
    super.key,
    required this.width,
    required this.day,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final double width;
  final String day;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          height: width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColor.primary.withValues(alpha: 0.15)
                : isToday
                ? AppColor.primary.withValues(alpha: 0.08)
                : AppColor.grey,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: selected
                  ? AppColor.primary
                  : isToday
                  ? AppColor.primary.withValues(alpha: 0.5)
                  : AppColor.greyBorder.withValues(alpha: 0.5),
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            day,
            style: AppTextStyle.body.copyWith(
              fontSize: 13.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColor.primary : AppColor.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
