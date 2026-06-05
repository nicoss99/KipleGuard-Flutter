import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../booking_strings.dart';

class BookingSearchEmptyState extends StatelessWidget {
  const BookingSearchEmptyState({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search_off_rounded, size: 48.sp, color: AppColor.textMuted),
        SizedBox(height: 16.h),
        Text(
          BookingStrings.searchNoResults(query),
          style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          BookingStrings.searchScopeHint,
          style: AppTextStyle.bodyMuted.copyWith(height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
