import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../login_theme.dart';
import 'login_region_data.dart';
import 'login_region_flag.dart';

Future<String?> showLoginRegionSheet(
  BuildContext context, {
  String? selectedCode,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColor.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => _LoginRegionSheetBody(selectedCode: selectedCode),
  );
}

class _LoginRegionSheetBody extends StatelessWidget {
  const _LoginRegionSheetBody({this.selectedCode});

  final String? selectedCode;

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
              'Select your region',
              style: LoginTheme.label(context).copyWith(
                color: AppColor.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Choose where your account is registered',
              style: LoginTheme.fieldText(context).copyWith(
                color: AppColor.textSecondary,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 16.h),
            ...loginRegionOptionsList.map((option) {
              final selected = selectedCode == option.code;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Material(
                  color: selected
                      ? AppColor.loginScreenBlue.withValues(alpha: 0.08)
                      : AppColor.grey.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () => Navigator.pop(context, option.code),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: selected ? AppColor.loginScreenBlue : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          LoginRegionFlag(
                            code: option.code,
                            size: 20.w,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              option.name,
                              style: LoginTheme.fieldText(context).copyWith(
                                color: AppColor.textPrimary,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_circle_rounded, color: AppColor.loginScreenBlue, size: 22.sp),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
