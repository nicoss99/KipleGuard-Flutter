import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../../../widget/app_progress_indicator.dart';
import '../visitor_state.dart';

class VisitorListFooter extends StatelessWidget {
  const VisitorListFooter({super.key, required this.state});

  final VisitorState state;

  @override
  Widget build(BuildContext context) {
    if (state.loadingMore) {
      return Container(
        margin: EdgeInsets.fromLTRB(AppSpacing.md, 8.h, AppSpacing.md, 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColor.greyBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20.w, height: 20.w, child: const AppProgressIndicator.compact()),
            SizedBox(width: 10.w),
            Text('Loading more…', style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp)),
          ],
        ),
      );
    }
    if (!state.hasMore && state.items.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.md, 8.h, AppSpacing.md, 16.h),
        child: Center(
          child: Text('End of list', style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp)),
        ),
      );
    }
    return SizedBox(height: 12.h);
  }
}
