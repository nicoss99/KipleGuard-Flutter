import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/profile_initials.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../register_strings.dart';
import 'register_gradient_button.dart';

/// Branded confirmation after visitor registration (replaces plain [AlertDialog]).
Future<void> showRegisterSuccessDialog(
  BuildContext context, {
  String? visitorName,
  String? unitLabel,
  String? visitTypeName,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => RegisterSuccessDialog(
      visitorName: visitorName,
      unitLabel: unitLabel,
      visitTypeName: visitTypeName,
    ),
  );
}

class RegisterSuccessDialog extends StatelessWidget {
  const RegisterSuccessDialog({
    super.key,
    this.visitorName,
    this.unitLabel,
    this.visitTypeName,
  });

  final String? visitorName;
  final String? unitLabel;
  final String? visitTypeName;

  @override
  Widget build(BuildContext context) {
    final name = visitorName?.trim() ?? '';
    final unit = unitLabel?.trim() ?? '';
    final type = visitTypeName?.trim() ?? '';

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.md, 28.h, AppSpacing.md, AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SuccessBadge(),
            SizedBox(height: 16.h),
            Text(RegisterStrings.success, style: AppTextStyle.title, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
            Text(
              RegisterStrings.successMessage,
              style: AppTextStyle.bodyMuted.copyWith(fontSize: 13.sp, height: 1.35),
              textAlign: TextAlign.center,
            ),
            if (name.isNotEmpty) ...[
              SizedBox(height: 20.h),
              _VisitorSummary(name: name, unit: unit, visitType: type),
            ],
            RegisterGradientButton(
              label: RegisterStrings.successDone,
              margin: EdgeInsets.only(top: 24.h),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.green.withValues(alpha: 0.14),
      ),
      child: Icon(Icons.check_rounded, size: 40.sp, color: AppColor.green),
    );
  }
}

class _VisitorSummary extends StatelessWidget {
  const _VisitorSummary({required this.name, required this.unit, required this.visitType});

  final String name;
  final String unit;
  final String visitType;

  @override
  Widget build(BuildContext context) {
    final initials = profileInitials(name);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.grey,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.white,
              border: Border.all(color: AppColor.primary, width: 1.5),
            ),
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (unit.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(unit, style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
                if (visitType.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(visitType, style: AppTextStyle.bodyMuted.copyWith(fontSize: 11.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
