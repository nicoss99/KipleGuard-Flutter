import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../select_site_strings.dart';

class SelectSiteSearchBar extends StatelessWidget {
  const SelectSiteSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 16.h, AppSpacing.md, AppSpacing.sm),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyle.body,
        decoration: InputDecoration(
          hintText: SelectSiteStrings.searchHint,
          hintStyle: AppTextStyle.bodyMuted,
          prefixIcon: Icon(Icons.search_rounded, color: AppColor.primary, size: 22.sp),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, _, _) {
              if (controller.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: Icon(Icons.close_rounded, size: 20.sp, color: AppColor.textSecondary),
              );
            },
          ),
          filled: true,
          fillColor: AppColor.grey,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
