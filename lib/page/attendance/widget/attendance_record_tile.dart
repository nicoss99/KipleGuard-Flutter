import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../attendance_model.dart';

class AttendanceRecordTile extends StatelessWidget {
  const AttendanceRecordTile({super.key, required this.row});

  final AttendanceRecordRow row;

  @override
  Widget build(BuildContext context) {
    final timeText = row.checkOutLabel != null && row.checkOutLabel!.isNotEmpty
        ? '${row.checkInLabel} to ${row.checkOutLabel}'
        : row.checkInLabel;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6.h),
      child: Material(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.r),
        elevation: 1,
        shadowColor: AppColor.textPrimary.withValues(alpha: 0.06),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: row.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: row.imageUrl,
                        width: 52.w,
                        height: 52.w,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.guardName, style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: 2.h),
                    Text(row.guardCode, style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp)),
                    SizedBox(height: 4.h),
                    Text(timeText, style: AppTextStyle.body.copyWith(fontSize: 12.sp)),
                  ],
                ),
              ),
              Icon(
                row.isCheckedInOnly ? Icons.login_rounded : Icons.logout_rounded,
                color: row.isCheckedInOnly ? AppColor.green : AppColor.textSecondary,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 52.w,
      height: 52.w,
      color: AppColor.grey,
      child: Icon(Icons.person, color: AppColor.textSecondary, size: 28.sp),
    );
  }
}
