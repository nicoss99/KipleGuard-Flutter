import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';

class SelectSiteStatusMessage extends StatelessWidget {
  const SelectSiteStatusMessage({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48.sp, color: AppColor.primary.withValues(alpha: 0.85)),
            SizedBox(height: AppSpacing.md),
            Text(title, textAlign: TextAlign.center, style: AppTextStyle.subtitle),
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(subtitle!, textAlign: TextAlign.center, style: AppTextStyle.bodyMuted),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(backgroundColor: AppColor.primary),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
