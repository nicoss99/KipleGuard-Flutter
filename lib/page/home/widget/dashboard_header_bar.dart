import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../dashboard_text_style.dart';

/// White bar under status bar: serif title + blue chevron (reference UI).
class DashboardHeaderBar extends StatelessWidget {
  const DashboardHeaderBar({super.key, required this.title, this.onTitleTap});

  final String title;
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      shadowColor: AppColor.textPrimary.withValues(alpha: 0.08),
      color: AppColor.white,
      child: InkWell(
        onTap: onTitleTap,
        child: SizedBox(
          height: 50.h,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: DashboardTextStyle.headerTitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.keyboard_arrow_down, color: AppColor.primary, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}
