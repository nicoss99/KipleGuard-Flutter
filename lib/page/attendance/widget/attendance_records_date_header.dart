import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';

/// Android `calendarView` — bold date row + calendar picker.
class AttendanceRecordsDateHeader extends StatelessWidget {
  const AttendanceRecordsDateHeader({
    super.key,
    required this.selectedDay,
    required this.onPickDate,
    required this.onShiftDay,
  });

  final DateTime selectedDay;
  final VoidCallback onPickDate;
  final ValueChanged<int> onShiftDay;

  @override
  Widget build(BuildContext context) {
    final dateLine = DateFormat('EEEE, d MMMM yyyy', 'en_US').format(selectedDay).toUpperCase();

    return ColoredBox(
      color: AppColor.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => onShiftDay(-1),
                  icon: Icon(Icons.chevron_left_rounded, size: 28.sp, color: AppColor.primary),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.w),
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPickDate,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                dateLine,
                                textAlign: TextAlign.center,
                                style: AppTextStyle.subtitle.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(Icons.calendar_month_rounded, size: 22.sp, color: AppColor.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onShiftDay(1),
                  icon: Icon(Icons.chevron_right_rounded, size: 28.sp, color: AppColor.primary),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.w),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
        ],
      ),
    );
  }
}
