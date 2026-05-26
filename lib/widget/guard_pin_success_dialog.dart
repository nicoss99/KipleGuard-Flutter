import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../page/reporting/reporting_strings.dart';
import '../theme/app_color.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_style.dart';

Future<void> showGuardPinSuccessDialog(
  BuildContext context, {
  String title = ReportingStrings.success,
  String message = ReportingStrings.pinSuccessMessage,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => GuardPinSuccessDialog(title: title, message: message),
  );
}

class GuardPinSuccessDialog extends StatelessWidget {
  const GuardPinSuccessDialog({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
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
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: Text(
                  ReportingStrings.successDone,
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
