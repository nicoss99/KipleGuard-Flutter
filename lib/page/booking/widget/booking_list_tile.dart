import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/profile_initials.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../visitor/visitor_text_style.dart';
import '../booking_model.dart';
import '../booking_strings.dart';

class BookingListTile extends StatelessWidget {
  const BookingListTile({
    super.key,
    required this.item,
    required this.stripeColor,
    required this.onTap,
  });

  final BookingListItem item;
  final Color stripeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = item.guardStatus == 'upcoming';
    final isCheckedIn = item.guardStatus == 'checked_in';
    final showAction = isUpcoming || isCheckedIn;
    final actionBg = isCheckedIn
        ? AppColor.red.withValues(alpha: 0.12)
        : AppColor.green.withValues(alpha: 0.12);
    final actionFg = isCheckedIn ? AppColor.red : AppColor.green;
    final actionLabel = isCheckedIn ? BookingStrings.checkOut : BookingStrings.checkIn;
    final initials = profileInitials(item.name);

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
                        _meta(
                          Icons.apartment_rounded,
                          item.unitLabel.trim().isEmpty ? '—' : item.unitLabel,
                        ),
                        SizedBox(height: 4.h),
                        _meta(
                          Icons.meeting_room_outlined,
                          item.bookingName.trim().isEmpty ? '—' : item.bookingName,
                        ),
                        SizedBox(height: 4.h),
                        _meta(
                          Icons.category_outlined,
                          item.category.trim().isEmpty ? '—' : item.category,
                        ),
                        if (item.timeRangeLabel.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          _meta(Icons.schedule_rounded, item.timeRangeLabel),
                        ],
                      ],
                    ),
                  ),
                ),
                if (showAction)
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 12.h, 12.w, 12.h),
                    child: Material(
                      color: actionBg,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: InkWell(
                        onTap: onTap,
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
                                textAlign: TextAlign.center,
                                maxLines: 2,
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
          child: Text(
            text,
            style: VisitorTextStyle.meta(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
