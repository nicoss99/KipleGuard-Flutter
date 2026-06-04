import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../l10n/app_l10n.dart';
import '../theme/app_color.dart';
import '../theme/app_text_style.dart';

/// Shared empty list placeholder (booking, visitor, attendance records).
class GuardListEmptyState extends StatelessWidget {
  const GuardListEmptyState({super.key});

  static const _icon = Icons.inbox_outlined;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_icon, size: 34.sp, color: AppColor.primary),
        ),
        SizedBox(height: 16.h),
        Text(
          appL10n.listEmptyTitle,
          style: AppTextStyle.subtitle.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColor.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          appL10n.listEmptyMessage,
          style: AppTextStyle.bodyMuted.copyWith(height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
