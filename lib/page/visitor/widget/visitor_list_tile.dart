import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/profile_initials.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../visitor_model.dart';
import '../visitor_text_style.dart';

class VisitorListTile extends StatelessWidget {
  const VisitorListTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onActionTap,
    required this.actionLabel,
    required this.stripeColor,
    required this.isCheckedIn,
    this.showActionButton = true,
  });

  final VisitorListItem item;
  final VoidCallback onTap;
  final VoidCallback onActionTap;
  final String actionLabel;
  final Color stripeColor;
  final bool isCheckedIn;
  final bool showActionButton;

  @override
  Widget build(BuildContext context) {
    final initials = profileInitials(item.name);
    final actionBg = isCheckedIn ? AppColor.red.withValues(alpha: 0.12) : AppColor.green.withValues(alpha: 0.12);
    final actionFg = isCheckedIn ? AppColor.red : AppColor.green;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Material(
        color: AppColor.white,
        elevation: 1,
        shadowColor: AppColor.textPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5.w, color: stripeColor),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 12.h, 8.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: AppColor.primary.withValues(alpha: 0.1),
                              child: Text(
                                initials,
                                style: VisitorTextStyle.visitorName().copyWith(
                                  fontSize: 13.sp,
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                item.name,
                                style: VisitorTextStyle.visitorName(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        _meta(Icons.apartment_rounded, item.unitLabel.trim().isEmpty ? '—' : item.unitLabel),
                        SizedBox(height: 4.h),
                        _meta(Icons.directions_car_outlined, item.carPlate.isEmpty ? '—' : item.carPlate),
                        SizedBox(height: 4.h),
                        _meta(Icons.badge_outlined, item.passId.isEmpty ? '—' : item.passId),
                      ],
                    ),
                  ),
                ),
                if (showActionButton)
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 12.h, 12.w, 12.h),
                    child: Material(
                      color: actionBg,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: InkWell(
                        onTap: onActionTap,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: SizedBox(
                          width: 72.w,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCheckedIn ? Icons.logout_rounded : Icons.login_rounded,
                                color: actionFg,
                                size: 26.sp,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                actionLabel,
                                style: VisitorTextStyle.meta().copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: actionFg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15.sp, color: AppColor.textSecondary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(text, style: VisitorTextStyle.meta(), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
