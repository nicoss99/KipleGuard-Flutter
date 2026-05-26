import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';

/// Shared search field for block / floor / unit steps on [UnitCallPage].
class UnitCallStepSearchField extends StatelessWidget {
  const UnitCallStepSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 10.h, AppSpacing.md, 6.h),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: AppColor.siteListRowGrey.withValues(alpha: 0.45),
          prefixIcon: Icon(Icons.search_rounded, color: AppColor.textSecondary, size: 22.sp),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12.h),
        ),
      ),
    );
  }
}
