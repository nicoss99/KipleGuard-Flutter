import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../profile_text_style.dart';

class EditProfileMenuRow extends StatelessWidget {
  const EditProfileMenuRow({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Expanded(child: Text(label, style: ProfileTextStyle.rowLabel)),
              Icon(Icons.chevron_right, color: AppColor.textSecondary, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}
