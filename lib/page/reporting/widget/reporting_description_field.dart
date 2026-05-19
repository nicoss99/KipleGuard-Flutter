import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportingSectionLabel(text: label, error: error),
        Container(
          width: double.infinity,
          color: AppColor.white,
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 5,
            minLines: 4,
            style: AppTextStyle.subtitle.copyWith(color: AppColor.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyle.subtitle.copyWith(color: AppColor.textSecondary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(10.w),
              filled: true,
              fillColor: AppColor.white,
            ),
            onChanged: onChanged,
          ),
        ),
        Container(
          height: 1,
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          color: error ? AppColor.red : AppColor.greyBorder,
        ),
      ],
    );
  }
}
