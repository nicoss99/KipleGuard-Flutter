import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

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

  String _rangeLabel() {
    final inFmt = DateFormat('yyyy-MM-dd HH:mm:ss');
    final outFmt = DateFormat('dd MMM yyyy, hh:mm a', 'en_US');
    try {
      final a = inFmt.parseUtc(item.startTimeRaw).toLocal();
      final b = inFmt.parseUtc(item.endTimeRaw).toLocal();
      return '${outFmt.format(a)} to ${outFmt.format(b)}';
    } catch (_) {
      return '${item.startTimeRaw} – ${item.endTimeRaw}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = item.isUpcomingTab ? AppColor.orange : AppColor.green;
    final chipLabel = item.isUpcomingTab
        ? BookingStrings.checkIn
        : BookingStrings.checkOut;

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
                      item.bookingName,
                      style: AppTextStyle.subtitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.bookingUnit,
                      style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item.roomName,
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
                      _rangeLabel(),
                      style: AppTextStyle.body.copyWith(fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                children: [
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
            ],
          ),
        ),
      ),
    );
  }
}
