import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../dashboard_strings.dart';

/// Mirrors Android `mainheader.xml`: centered title + trailing dropdown affordance.
class DashboardHeaderBar extends StatelessWidget {
  const DashboardHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: AppColor.white,
      child: SizedBox(
        height: 60.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DashboardStrings.appTitle,
              style: AppTextStyle.title.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: AppColor.textPrimary, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
