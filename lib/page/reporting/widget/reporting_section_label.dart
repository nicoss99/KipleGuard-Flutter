import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';

class ReportingSectionLabel extends StatelessWidget {
  const ReportingSectionLabel({super.key, required this.text, this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Text(
        text,
        style: AppTextStyle.subtitle.copyWith(
          fontWeight: FontWeight.w600,
          color: error ? AppColor.red : AppColor.textPrimary,
        ),
      ),
    );
  }
}
