import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../theme/app_color.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_style.dart';
import '../call_recent_format.dart';
import '../call_recent_models.dart';

class CallRecentTile extends StatelessWidget {
  const CallRecentTile({
    super.key,
    required this.row,
    required this.residenceDisplayName,
    required this.onTap,
  });

  final CallHistoryRow row;
  final String residenceDisplayName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parsed = parseCallAtGmt(row.callAtRaw);
    final local = parsed?.toLocal();
    final dateLabel = local != null ? formatRecentDateLabel(local) : '—';
    final timeLabel = local != null ? formatRecentTime(local) : '—';

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, left: AppSpacing.md, right: AppSpacing.md),
      child: Material(
        color: AppColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: AppColor.primary.withValues(alpha: 0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.history_rounded, color: AppColor.primary, size: 22.sp),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.unitName, style: AppTextStyle.subtitle),
                      SizedBox(height: 2.h),
                      Text(residenceDisplayName, style: AppTextStyle.bodyMuted),
                      SizedBox(height: 8.h),
                      Text(row.receiverName, style: AppTextStyle.body),
                      Text(
                        row.receiverTypeLabel,
                        style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
                      ),
                      if (row.callStatus.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          row.callStatus,
                          style: AppTextStyle.bodyMuted.copyWith(fontSize: 11.sp),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(dateLabel, style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp)),
                    SizedBox(height: 4.h),
                    Text(timeLabel, style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w500)),
                    SizedBox(height: 8.h),
                    Icon(Icons.phone_forwarded_rounded, color: AppColor.primary, size: 22.sp),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
