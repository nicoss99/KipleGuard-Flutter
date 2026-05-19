import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_text_style.dart';

/// Branded day picker for visitor filter (dialog — same pattern as booking/attendance).
Future<DateTime?> showVisitorDayPicker({
  required BuildContext context,
  required DateTime selected,
}) async {
  final day = DateTime(selected.year, selected.month, selected.day);
  final values = await showCalendarDatePicker2Dialog(
    context: context,
    dialogSize: Size(340.w, 400.h),
    borderRadius: BorderRadius.circular(AppRadius.md),
    value: [day],
    config: CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.single,
      firstDate: DateTime(day.year - 1, 1, 1),
      lastDate: DateTime(day.year + 2, 12, 31),
      currentDate: DateTime.now(),
      centerAlignModePicker: true,
      selectedDayHighlightColor: AppColor.primary,
      todayTextStyle: AppTextStyle.body.copyWith(
        color: AppColor.primary,
        fontWeight: FontWeight.w700,
      ),
      selectedDayTextStyle: AppTextStyle.body.copyWith(
        color: AppColor.white,
        fontWeight: FontWeight.w700,
      ),
      dayTextStyle: AppTextStyle.body.copyWith(fontSize: 14.sp),
      weekdayLabelTextStyle: AppTextStyle.bodyMuted.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      controlsTextStyle: AppTextStyle.subtitle.copyWith(fontSize: 15.sp),
      okButton: Text('Apply', style: AppTextStyle.subtitle.copyWith(color: AppColor.primary)),
      cancelButton: Text('Cancel', style: AppTextStyle.bodyMuted),
    ),
  );
  final picked = values?.isNotEmpty == true ? values!.first : null;
  if (picked == null) return null;
  return DateTime(picked.year, picked.month, picked.day);
}
