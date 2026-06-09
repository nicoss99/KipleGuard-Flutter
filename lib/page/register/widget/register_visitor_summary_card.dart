import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/profile_initials.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../register_strings.dart';
import '../register_visitor_draft.dart';

/// Android `activity_createvisit.xml` `visitorRelativeLayout` — circle avatar, name, phone, delete.
class RegisterVisitorSummaryCard extends StatelessWidget {
  const RegisterVisitorSummaryCard({
    super.key,
    required this.visitor,
    required this.onEdit,
    required this.onClear,
  });

  final RegisterVisitorDraft visitor;
  final VoidCallback onEdit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final initials = profileInitials(visitor.name);
    return Material(
      color: AppColor.white,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Row(
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.white,
                border: Border.all(color: AppColor.primary, width: 2),
              ),
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: AppTextStyle.subtitle.copyWith(color: AppColor.textPrimary),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visitor.name,
                    style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14.sp, color: AppColor.textPrimary),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          visitor.mobile.isEmpty ? 'N/A' : visitor.mobile,
                          style: AppTextStyle.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              padding: EdgeInsets.all(5.w),
              constraints: const BoxConstraints(),
              icon: Icon(Icons.edit_outlined, color: AppColor.primary, size: 22.sp),
              tooltip: RegisterStrings.editVisitor,
              onPressed: onEdit,
            ),
            IconButton(
              padding: EdgeInsets.all(5.w),
              constraints: const BoxConstraints(),
              icon: Icon(Icons.cancel, color: AppColor.red, size: 24.sp),
              onPressed: onClear,
            ),
          ],
        ),
      ),
    );
  }
}
