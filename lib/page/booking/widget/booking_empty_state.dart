import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../booking_state.dart';
import '../booking_strings.dart';
import '../booking_tab_colors.dart';

class BookingEmptyState extends StatelessWidget {
  const BookingEmptyState({
    super.key,
    required this.tab,
    required this.selectedDay,
    required this.message,
  });

  final BookingTab tab;
  final DateTime selectedDay;
  final String message;

  @override
  Widget build(BuildContext context) {
    final accent = BookingTabColors.stripeForTab(tab);
    final dayLabel = _dayLabel(selectedDay);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Material(
        color: AppColor.white,
        elevation: 1,
        shadowColor: AppColor.textPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border(
              left: BorderSide(color: accent, width: 4.w),
            ),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  BookingTabColors.iconForTab(tab),
                  size: 34.sp,
                  color: accent,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                BookingTabColors.tabLabel(tab),
                style: AppTextStyle.subtitle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColor.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                style: AppTextStyle.bodyMuted.copyWith(height: 1.4),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColor.lightGreyBar,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14.sp, color: AppColor.textSecondary),
                    SizedBox(width: 6.w),
                    Text(
                      dayLabel,
                      style: AppTextStyle.body.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, size: 16.sp, color: AppColor.primary),
                  SizedBox(width: 6.w),
                  Text(
                    BookingStrings.emptyRefreshHint,
                    style: AppTextStyle.bodyMuted.copyWith(
                      fontSize: 12.sp,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
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

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    if (day.year == now.year && day.month == now.month && day.day == now.day) {
      return BookingStrings.today;
    }
    return DateFormat('dd MMM yyyy').format(day);
  }
}
