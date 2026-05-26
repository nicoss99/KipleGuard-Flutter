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
    this.onGreetingTap,
  });

  final String userName;
  final String userEmail;
  final String profileInitial;
  final VoidCallback? onGreetingTap;

  @override
  Widget build(BuildContext context) {
    final welcome = userName.isEmpty ? DashboardStrings.welcomeUser : 'Hi, $userName';
    final arcDepth = 16.h;
    final heroHeight = 128.h;

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
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onGreetingTap,
                borderRadius: BorderRadius.circular(32.r),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32.r),
                    border: Border.all(color: AppColor.white, width: 1.5),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 48.h),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 15.r,
                            backgroundColor: AppColor.white,
                            child: profileInitial.isNotEmpty
                                ? Text(profileInitial, style: DashboardTextStyle.heroInitials())
                                : Icon(Icons.person, color: AppColor.primary, size: 17.sp),
                          ),
                          SizedBox(width: 10.w),
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
                  ),
                ),
              ),
            ),
            if (userEmail.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                userEmail,
                style: DashboardTextStyle.heroEmail(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
