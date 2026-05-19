import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../attendance_state.dart';
import '../attendance_strings.dart';

Future<void> showAttendanceShiftSuccessDialog(
  BuildContext context, {
  required AttendanceShiftFlow flow,
}) {
  final isStart = flow == AttendanceShiftFlow.startShift;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _AttendanceShiftSuccessDialog(isStart: isStart),
  );
}

class _AttendanceShiftSuccessDialog extends StatelessWidget {
  const _AttendanceShiftSuccessDialog({required this.isStart});

  final bool isStart;

  @override
  Widget build(BuildContext context) {
    final accent = isStart ? AppColor.primary : AppColor.red;
    final title = isStart ? AttendanceStrings.shiftStarted : AttendanceStrings.shiftEnded;
    final message =
        isStart ? AttendanceStrings.shiftStartedMessage : AttendanceStrings.shiftEndedMessage;
    final actionTitle =
        isStart ? AttendanceStrings.startShiftTitle : AttendanceStrings.endShiftTitle;
    final actionSubtitle =
        isStart ? AttendanceStrings.startShiftSubtitle : AttendanceStrings.endShiftSubtitle;
    final timeLabel = DateFormat('dd MMM yyyy · HH:mm').format(DateTime.now());

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.md, 28.h, AppSpacing.md, AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.green.withValues(alpha: 0.14),
              ),
              child: Icon(Icons.check_rounded, size: 40.sp, color: AppColor.green),
            ),
            SizedBox(height: 16.h),
            Text(title, style: AppTextStyle.title, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTextStyle.bodyMuted.copyWith(fontSize: 13.sp, height: 1.35),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColor.grey,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      isStart ? Icons.login_rounded : Icons.logout_rounded,
                      color: accent,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actionTitle,
                          style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          actionSubtitle,
                          style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          timeLabel,
                          style: AppTextStyle.bodyMuted.copyWith(
                            fontSize: 11.sp,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  AttendanceStrings.successDone,
                  style: AppTextStyle.subtitle.copyWith(color: AppColor.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
