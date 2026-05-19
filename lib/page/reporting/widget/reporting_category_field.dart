import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../reporting_models.dart';
import '../reporting_strings.dart';
import 'reporting_category_icon.dart';
import 'reporting_picker_field.dart';
import 'reporting_section_label.dart';

class ReportingCategoryField extends StatelessWidget {
  const ReportingCategoryField({
    super.key,
    required this.label,
    required this.loading,
    required this.categories,
    required this.selectedUuid,
    required this.error,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final List<ReportingCategory> categories;
  final String? selectedUuid;
  final bool error;
  final VoidCallback onTap;

  ReportingCategory? get _selected {
    if (selectedUuid == null) return null;
    for (final c in categories) {
      if (c.uuid == selectedUuid) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportingSectionLabel(text: label, error: error),
        SizedBox(height: 8.h),
        if (loading)
          const LinearProgressIndicator()
        else
          ReportingPickerField(
            hint: ReportingStrings.reportTypeHint,
            valueText: selected?.name,
            emptyIcon: Icons.category_outlined,
            enabled: categories.isNotEmpty,
            onTap: onTap,
            leading: selected != null
                ? reportingCategoryIcon(selected.name, selected: true, size: 22)
                : null,
          ),
      ],
    );
  }
}
