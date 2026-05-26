import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../reporting_models.dart';
import '../reporting_strings.dart';
import 'reporting_category_icon.dart';
import 'reporting_sheet_option.dart';

Future<String?> showReportingCategorySheet(
  BuildContext context, {
  required List<ReportingCategory> categories,
  String? selectedKey,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColor.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => _ReportingCategorySheetBody(
      categories: categories,
      selectedKey: selectedKey,
    ),
  );
}

class _ReportingCategorySheetBody extends StatelessWidget {
  const _ReportingCategorySheetBody({
    required this.categories,
    this.selectedKey,
  });

  final List<ReportingCategory> categories;
  final String? selectedKey;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ReportingStrings.reportType,
              style: AppTextStyle.title.copyWith(
                color: AppColor.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              ReportingStrings.reportTypeSheetSubtitle,
              style: AppTextStyle.body.copyWith(color: AppColor.textSecondary, fontSize: 13.sp),
            ),
            SizedBox(height: 16.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.45),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: categories.length,
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
                itemBuilder: (_, i) {
                  final c = categories[i];
                  final selected = c.key == selectedKey;
                  return ReportingSheetOption(
                    selected: selected,
                    leading: reportingCategoryIcon(
                      c.label,
                      selected: selected,
                      size: 20,
                    ),
                    label: c.label,
                    onTap: () => Navigator.pop(context, c.key),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
