import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';

/// Android `calendarImageView` — large calendar tap target on the right.
class VisitorCalendarButton extends StatelessWidget {
  const VisitorCalendarButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 4.w, top: 4.h, bottom: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 52.w,
            height: 52.w,
            child: Icon(
              Icons.calendar_month_rounded,
              size: 28.sp,
              color: AppColor.primary,
            ),
          ),
        ),
      ),
    );
  }
}
