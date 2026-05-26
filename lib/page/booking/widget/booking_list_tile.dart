import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../booking_model.dart';
import '../booking_strings.dart';

class BookingListTile extends StatelessWidget {
  const BookingListTile({super.key, required this.item, required this.onTap});

  final BookingListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = item.guardStatus == 'upcoming';
    final chipColor = isUpcoming ? AppColor.orange : AppColor.green;
    final chipLabel =
        isUpcoming ? BookingStrings.checkIn : BookingStrings.checkOut;

    return Material(
      color: AppColor.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyle.subtitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.unitLabel,
                      style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item.bookingName,
                      style: AppTextStyle.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.category,
                      style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item.timeRangeLabel,
                      style: AppTextStyle.body.copyWith(fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (isUpcoming || item.guardStatus == 'checked_in')
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    chipLabel,
                    style: AppTextStyle.body.copyWith(
                      color: AppColor.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
