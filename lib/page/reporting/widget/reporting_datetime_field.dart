import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'reporting_picker_field.dart';
import 'reporting_section_label.dart';

class ReportingDateTimeField extends StatelessWidget {
  const ReportingDateTimeField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.error,
    required this.onTap,
  });

  final String label;
  final String hint;
  final String value;
  final bool error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final empty = value.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportingSectionLabel(text: label, error: error),
        SizedBox(height: 8.h),
        ReportingPickerField(
          hint: hint,
          valueText: empty ? null : value,
          emptyIcon: Icons.event_outlined,
          onTap: onTap,
        ),
      ],
    );
  }
}
