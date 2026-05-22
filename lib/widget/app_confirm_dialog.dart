import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_color.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_style.dart';

/// Card-style confirm dialog (aligned with kipleHomev2 [AppConfirmDialog]).
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    required this.message,
    this.showCancel = true,
    required this.confirmText,
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.confirmResult,
    this.confirmButtonColor,
  });

  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String message;
  final bool showCancel;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final dynamic confirmResult;
  final Color? confirmButtonColor;

  @override
  Widget build(BuildContext context) {
    final confirmColor = confirmButtonColor ?? AppColor.primary;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400.w),
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Center(
                child: Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? AppColor.errorLight,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 32.sp,
                    color: iconColor ?? AppColor.errorStrong,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
            ],
            Text(title, textAlign: TextAlign.center, style: AppTextStyle.title),
            SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyMuted.copyWith(height: 1.35),
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                if (showCancel) ...[
                  Expanded(child: _cancelButton(context)),
                  SizedBox(width: AppSpacing.md),
                ],
                Expanded(child: _confirmButton(context, confirmColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cancelButton(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(confirmResult == null ? null : false),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.textSecondary,
          side: const BorderSide(color: AppColor.greyBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
        child: Text(
          cancelText,
          style: AppTextStyle.subtitle.copyWith(
            color: AppColor.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _confirmButton(BuildContext context, Color confirmColor) {
    return SizedBox(
      height: 48.h,
      child: FilledButton(
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            if (confirmResult != null) {
              Navigator.of(context).pop(confirmResult);
            } else {
              Navigator.of(context).pop();
            }
            onConfirm?.call();
          });
        },
        style: FilledButton.styleFrom(
          backgroundColor: confirmColor,
          foregroundColor: AppColor.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
        child: Text(
          confirmText,
          style: AppTextStyle.subtitle.copyWith(
            color: AppColor.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Generic two-button confirm — returns `true` when confirmed.
Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  IconData? icon,
  Color? iconColor,
  Color? iconBackgroundColor,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  Color? confirmButtonColor,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AppConfirmDialog(
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      title: title,
      message: message,
      cancelText: cancelLabel,
      confirmText: confirmLabel,
      confirmButtonColor: confirmButtonColor,
      confirmResult: true,
    ),
  );
}
