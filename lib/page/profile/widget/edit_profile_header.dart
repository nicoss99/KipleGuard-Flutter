import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../profile_text_style.dart';

/// Blue banner + overlapping avatar (Android `activity_editprofile` header).
class EditProfileHeader extends StatelessWidget {
  const EditProfileHeader({super.key, required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final avatarSize = 100.r;
    final bannerH = 80.h;

    return SizedBox(
      height: bannerH + avatarSize / 2 + 8.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            height: bannerH,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColor.primaryDark, AppColor.primary],
              ),
            ),
          ),
          Positioned(
            top: bannerH - avatarSize / 2,
            child: Material(
              elevation: 2,
              shadowColor: AppColor.textPrimary.withValues(alpha: 0.12),
              shape: const CircleBorder(),
              color: AppColor.white,
              child: SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: Center(
                  child: Text(initials, style: ProfileTextStyle.avatarInitials),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
