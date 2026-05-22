import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import '../../widget/standard_primary_header.dart';
import 'profile_strings.dart';

/// Placeholder for Android `OfflineActivity` (visitor sync queue — not yet ported).
class ProfileOfflinePage extends StatelessWidget {
  const ProfileOfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: Column(
          children: [
            StandardPrimaryHeader(
              title: ProfileStrings.offlineData,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Text(
                    ProfileStrings.emptyOfflineData,
                    style: AppTextStyle.bodyMuted,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
