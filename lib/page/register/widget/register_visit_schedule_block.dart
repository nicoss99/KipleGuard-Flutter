import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_text_style.dart';
import '../register_strings.dart';
import 'register_section_label.dart';
import 'register_time_field.dart';

class RegisterVisitScheduleBlock extends StatelessWidget {
  const RegisterVisitScheduleBlock({
    super.key,
    required this.startText,
    required this.endText,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onClearEnd,
  });

  final String startText;
  final String endText;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onClearEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RegisterSectionLabel(RegisterStrings.visitStart),
        SizedBox(height: 10.h),
        RegisterTimeField(label: '', valueText: startText, onPick: onPickStart),
        SizedBox(height: 16.h),
        RegisterSectionLabel(RegisterStrings.visitEnd),
        SizedBox(height: 10.h),
        RegisterTimeField(
          label: '',
          valueText: endText,
          onPick: onPickEnd,
          onClear: onClearEnd,
        ),
        SizedBox(height: 8.h),
        Text(RegisterStrings.visitEndHint, style: AppTextStyle.bodyMuted),
      ],
    );
  }
}
