import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../reporting_strings.dart';
import 'reporting_category_icon.dart';

Future<void> showReportingSuccessDialog(
  BuildContext context, {
  required String categoryName,
  required String dateLabel,
  required int photoCount,
  required bool queuedOffline,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => ReportingSuccessDialog(
      categoryName: categoryName,
      dateLabel: dateLabel,
      photoCount: photoCount,
      queuedOffline: queuedOffline,
    ),
  );
}

class ReportingSuccessDialog extends StatelessWidget {
  const ReportingSuccessDialog({
    super.key,
    required this.categoryName,
    required this.dateLabel,
    required this.photoCount,
    required this.queuedOffline,
  });

  final String categoryName;
  final String dateLabel;
  final int photoCount;
  final bool queuedOffline;

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
            Text(ReportingStrings.reportSuccessTitle, style: AppTextStyle.title, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
            Text(
              queuedOffline ? ReportingStrings.reportSuccessQueued : ReportingStrings.reportSuccessMessage,
              style: AppTextStyle.bodyMuted.copyWith(fontSize: 13.sp, height: 1.35),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            _SummaryCard(categoryName: categoryName, dateLabel: dateLabel, photoCount: photoCount),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.categoryName,
    required this.dateLabel,
    required this.photoCount,
  });

  final String categoryName;
  final String dateLabel;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.grey,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: reportingCategoryIcon(categoryName, selected: true, size: 24),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dateLabel.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.event_outlined, size: 14.sp, color: AppColor.textSecondary),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          dateLabel,
                          style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (photoCount > 0) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '$photoCount ${photoCount == 1 ? ReportingStrings.photoAttachedOne : ReportingStrings.photoAttachedMany}',
                    style: AppTextStyle.bodyMuted.copyWith(
                      fontSize: 11.sp,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
