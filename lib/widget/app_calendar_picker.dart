import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_date_limits.dart';
import '../theme/app_color.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_style.dart';

/// Branded single-day calendar dialog (shared across visitor, attendance, booking, etc.).
abstract final class AppCalendarPicker {
  AppCalendarPicker._();

  static DateTime defaultLastDate([DateTime? from]) {
    final y = (from ?? DateTime.now()).year;
    return DateTime(y + 2, 12, 31);
  }

  static Future<DateTime?> showDay({
    required BuildContext context,
    required DateTime initial,
    DateTime? firstDate,
    DateTime? lastDate,
    String okLabel = 'OK',
    String cancelLabel = 'Cancel',
  }) async {
    final day = DateTime(initial.year, initial.month, initial.day);
    final values = await showCalendarDatePicker2Dialog(
      context: context,
      dialogSize: Size(330.w, 420.h),
      borderRadius: BorderRadius.circular(AppRadius.md),
      value: [day],
      config: _dayConfig(
        firstDate: firstDate ?? AppDateLimits.calendarFirstDate,
        lastDate: lastDate ?? defaultLastDate(day),
        okLabel: okLabel,
        cancelLabel: cancelLabel,
      ),
    );
    final picked = values?.isNotEmpty == true ? values!.first : null;
    if (picked == null) return null;
    return DateTime(picked.year, picked.month, picked.day);
  }

  /// Calendar day, then Material time picker (register visit, reporting datetime).
  static Future<DateTime?> showDayAndTime({
    required BuildContext context,
    required DateTime initial,
    DateTime? lastDate,
    String? helpText,
    String cancelText = 'Cancel',
    String confirmText = 'OK',
  }) async {
    final day = await showDay(
      context: context,
      initial: initial,
      lastDate: lastDate,
      okLabel: confirmText,
      cancelLabel: cancelText,
    );
    if (day == null || !context.mounted) return null;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      builder: (ctx, child) => _materialPickerTheme(ctx, child),
    );
    if (t == null || !context.mounted) return null;
    return DateTime(day.year, day.month, day.day, t.hour, t.minute);
  }

  static Widget _materialPickerTheme(BuildContext context, Widget? child) {
    if (child == null) return const SizedBox.shrink();
    final base = Theme.of(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: Theme(
        data: base.copyWith(
          colorScheme: base.colorScheme.copyWith(
            primary: AppColor.primary,
            onPrimary: AppColor.white,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: AppColor.white),
        ),
        child: child,
      ),
    );
  }

  static CalendarDatePicker2WithActionButtonsConfig _dayConfig({
    required DateTime firstDate,
    required DateTime lastDate,
    required String okLabel,
    required String cancelLabel,
  }) =>
      CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        firstDate: firstDate,
        lastDate: lastDate,
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
        okButton: _actionLabel(okLabel, primary: true),
        cancelButton: _actionLabel(cancelLabel, primary: false),
      );

  static Widget _actionLabel(String label, {required bool primary}) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Text(
          label,
          style: primary
              ? AppTextStyle.subtitle.copyWith(color: AppColor.primary)
              : AppTextStyle.bodyMuted,
        ),
      );
}
