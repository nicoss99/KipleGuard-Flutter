import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/profile_initials.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../visitor_model.dart';

class VisitorListTile extends StatelessWidget {
  const VisitorListTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onActionTap,
    required this.actionLabel,
  });

  final VisitorListItem item;
  final VoidCallback onTap;
  final VoidCallback onActionTap;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final initials = profileInitials(item.name);
    final stripeColor = switch (item.latestScanType.toUpperCase()) {
      'IN' => AppColor.red,
      'OUT' => AppColor.green,
      _ => AppColor.orange,
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.textSecondary.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 6.w,
                  decoration: BoxDecoration(
                    color: stripeColor,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(10.r)),
                  ),
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10.w, 12.h, 8.w, 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34.w,
                                height: 34.w,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.primary, width: 1.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(initials, style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w600, color: AppColor.primary)),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          _metaRow(Icons.apartment, item.unitLabel.trim().isEmpty ? 'N/A' : item.unitLabel),
                          SizedBox(height: 4.h),
                          _metaRow(Icons.directions_car, item.carPlate.isEmpty ? 'N/A' : item.carPlate),
                          SizedBox(height: 4.h),
                          _metaRow(Icons.badge_outlined, item.passId.isEmpty ? 'N/A' : item.passId),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: InkWell(
                      onTap: onActionTap,
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        width: 88.w,
                        height: 84.h,
                        decoration: BoxDecoration(
                          color: AppColor.grey.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: AppColor.textPrimary, size: 30.sp),
                            SizedBox(height: 4.h),
                            Text(actionLabel, style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColor.textPrimary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyle.body.copyWith(fontSize: 13.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
