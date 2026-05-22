import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_bar_title_format.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';

/// Android dashboard-style header card (`header` inside `CardView` elevation 2).
class ReportingPageHeader extends StatelessWidget {
  const ReportingPageHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: AppColor.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: AppColor.primary),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Text(
                  AppBarTitleFormat.format(title),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.title.copyWith(fontSize: 18.sp),
                ),
              ),
              SizedBox(width: 48.w),
            ],
          ),
        ),
      ),
    );
  }
}
