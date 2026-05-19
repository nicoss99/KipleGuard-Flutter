import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_text_style.dart';

/// Android `allovertimeCardView` — white card, orange border when idle.
class VisitorAllOvertimeCard extends StatelessWidget {
  const VisitorAllOvertimeCard({
    super.key,
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 6.w, top: 6.h, bottom: 6.h),
      child: Material(
        elevation: 2,
        shadowColor: AppColor.textPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? AppColor.orange : AppColor.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: AppColor.orange,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 88.w,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'All',
                      style: AppTextStyle.body.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColor.white : AppColor.textPrimary,
                      ),
                    ),
                    Text(
                      'Overtime',
                      style: AppTextStyle.body.copyWith(
                        fontSize: 12.sp,
                        color: selected
                            ? AppColor.white.withValues(alpha: 0.95)
                            : AppColor.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
