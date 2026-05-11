import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';

/// Month navigation + tappable full date row for the attendance records tab.
class AttendanceRecordsDateHeader extends StatelessWidget {
  const AttendanceRecordsDateHeader({
    super.key,
    required this.selectedDay,
    required this.onPickDate,
    required this.onShiftMonth,
  });

  final DateTime selectedDay;
  final VoidCallback onPickDate;
  final ValueChanged<int> onShiftMonth;

  @override
  Widget build(BuildContext context) {
    final monthYear = DateFormat('MMMM yyyy', 'en_US').format(selectedDay);
    final dateLine = DateFormat(
      'EEEE, d MMMM yyyy',
      'en_US',
    ).format(selectedDay);

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 12.h, AppSpacing.md, 10.h),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColor.greyBorder.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.textPrimary.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 44.h,
              child: Row(
                children: [
                  _MonthNavIcon(
                    icon: Icons.chevron_left_rounded,
                    onPressed: () => onShiftMonth(-1),
                  ),
                  Expanded(
                    child: Text(
                      monthYear,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.subtitle.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                  _MonthNavIcon(
                    icon: Icons.chevron_right_rounded,
                    onPressed: () => onShiftMonth(1),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: AppColor.greyBorder.withValues(alpha: 0.35),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPickDate,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.md),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          dateLine,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.body.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColor.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.calendar_month_rounded,
                        color: AppColor.primary,
                        size: 24.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthNavIcon extends StatelessWidget {
  const _MonthNavIcon({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 28.sp),
      color: AppColor.primary,
      style: IconButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        minimumSize: Size(40.w, 40.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
