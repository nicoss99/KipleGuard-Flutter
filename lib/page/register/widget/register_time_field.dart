import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';

/// Read-only date/time field styled like Android `activity_createvisit.xml` card EditText.
class RegisterTimeField extends StatelessWidget {
  const RegisterTimeField({
    super.key,
    required this.label,
    required this.valueText,
    required this.onPick,
    this.onClear,
  });

  final String label;
  final String valueText;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Text(label, style: AppTextStyle.bodyMuted),
        ),
        Row(
          children: [
            Expanded(child: _card(context)),
            if (onClear != null && valueText.isNotEmpty)
              TextButton(onPressed: onClear, child: const Text('Clear')),
          ],
        ),
      ],
    );
  }

  Widget _card(BuildContext context) {
    final hasValue = valueText.isNotEmpty;
    return Material(
      color: AppColor.white,
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasValue ? valueText : 'Tap to set',
                  style: hasValue
                      ? AppTextStyle.body.copyWith(color: AppColor.textPrimary)
                      : AppTextStyle.body.copyWith(color: AppColor.textSecondary),
                ),
              ),
              Icon(Icons.calendar_today_outlined, size: 18.sp, color: AppColor.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

String formatUtcApi(DateTime dt) => DateFormat('yyyy-MM-dd HH:mm:ss').format(dt.toUtc());
