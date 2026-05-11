import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../dashboard_strings.dart';
import '../dashboard_text_style.dart';
import 'dashboard_hero_arc_clipper.dart';

/// Blue gradient hero with curved bottom + pill (initials + greeting) + email.
class DashboardHeroSection extends StatelessWidget {
  const DashboardHeroSection({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.profileInitial,
    required this.qrEnabled,
    this.onViewQr,
  });

  final String userName;
  final String userEmail;
  final String profileInitial;
  final bool qrEnabled;
  final VoidCallback? onViewQr;

  @override
  Widget build(BuildContext context) {
    final welcome = userName.isEmpty ? DashboardStrings.welcomeUser : 'Hi, $userName';
    final arcDepth = 22.h;
    final heroHeight = 158.h;

    return ClipPath(
      clipper: DashboardHeroArcClipper(arcDepth: arcDepth),
      child: Container(
        width: double.infinity,
        height: heroHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColor.primaryDark, AppColor.primary],
          ),
        ),
        padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 28.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32.r),
                border: Border.all(color: AppColor.white, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColor.white,
                    child: profileInitial.isNotEmpty
                        ? Text(profileInitial, style: DashboardTextStyle.heroInitials())
                        : Icon(Icons.person, color: AppColor.primary, size: 18.sp),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      welcome,
                      style: DashboardTextStyle.heroPillGreeting(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (!qrEnabled && userEmail.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Text(
                userEmail,
                style: DashboardTextStyle.heroEmail(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (qrEnabled) ...[
              SizedBox(height: 12.h),
              TextButton(
                onPressed: onViewQr,
                child: Text(
                  DashboardStrings.viewQr,
                  style: DashboardTextStyle.heroEmail().copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColor.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
