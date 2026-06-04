import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_text_style.dart';
import 'reporting_section_label.dart';

class ReportingDescriptionField extends StatelessWidget {
  const ReportingDescriptionField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.error,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderColor = error
        ? AppColor.red
        : AppColor.greyBorder.withValues(alpha: 0.35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportingSectionLabel(text: label, error: error),
        SizedBox(height: 8.h),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: borderColor, width: error ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 5,
            minLines: 4,
            style: AppTextStyle.body.copyWith(color: AppColor.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyle.body.copyWith(color: AppColor.textSecondary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              filled: true,
              fillColor: AppColor.white,
              alignLabelWithHint: true,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
