import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_assets.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../dashboard_strings.dart';

/// Header strip + profile row matching `activity_dashboard.xml` (banner + avatar).
class DashboardHeroSection extends StatelessWidget {
  const DashboardHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 50.h, bottom: 40.h, left: 50.w, right: 50.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColor.primary, AppColor.primaryDark],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 22.r,
              backgroundColor: AppColor.white,
              child: ClipOval(
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Image.asset(
                    AppAssets.kipleGuardIcon,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            DashboardStrings.welcomeUser,
            style: AppTextStyle.body.copyWith(
              color: AppColor.white,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
