import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';

/// Bottom sheet: view QR or share invitation (no cancel row — dismiss via drag or scrim).
Future<void> showVisitorEpassActionsSheet(
  BuildContext context, {
  required VoidCallback onViewQr,
  required VoidCallback onShareText,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(left: AppSpacing.sm, right: AppSpacing.sm, bottom: AppSpacing.sm),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: AppColor.textPrimary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, 10.h, AppSpacing.md, AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColor.greyBorder,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Share e-Pass',
                    style: AppTextStyle.title.copyWith(fontSize: 18.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'View the QR code or send the invitation message with link to your visitor.',
                    style: AppTextStyle.bodyMuted.copyWith(fontSize: 13.sp, height: 1.35),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  _SheetActionTile(
                    icon: Icons.qr_code_2_rounded,
                    title: 'View QR code',
                    subtitle: 'Full-screen code for scanning',
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onViewQr();
                    },
                  ),
                  SizedBox(height: 10.h),
                  _SheetActionTile(
                    icon: Icons.share_rounded,
                    title: 'Share invitation',
                    subtitle: 'Message with HDF link via your apps',
                    isPrimary: true,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onShareText();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _SheetActionTile extends StatelessWidget {
  const _SheetActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = Border.all(
      color: isPrimary ? AppColor.primary : AppColor.greyBorder,
      width: isPrimary ? 2 : 1,
    );
    final bg = isPrimary ? AppColor.primary.withValues(alpha: 0.06) : AppColor.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14.r),
            border: border,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: isPrimary ? AppColor.primary.withValues(alpha: 0.12) : AppColor.grey,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, size: 24.sp, color: isPrimary ? AppColor.primary : AppColor.textPrimary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: 2.h),
                      Text(subtitle, style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 22.sp, color: AppColor.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
