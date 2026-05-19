import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';

/// Trigger row — same interaction as login [LoginRegionField] on a white card.
class ReportingPickerField extends StatefulWidget {
  const ReportingPickerField({
    super.key,
    required this.hint,
    required this.valueText,
    required this.onTap,
    this.leading,
    this.emptyIcon = Icons.touch_app_outlined,
    this.enabled = true,
  });

  final String hint;
  final String? valueText;
  final VoidCallback? onTap;
  final Widget? leading;
  final IconData emptyIcon;
  final bool enabled;

  @override
  State<ReportingPickerField> createState() => _ReportingPickerFieldState();
}

class _ReportingPickerFieldState extends State<ReportingPickerField> {
  var _pressed = false;

  bool get _hasValue => widget.valueText != null && widget.valueText!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final canTap = widget.enabled && widget.onTap != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: _pressed ? AppColor.primary.withValues(alpha: 0.45) : AppColor.greyBorder.withValues(alpha: 0.35),
          width: _pressed ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _pressed ? 0.12 : 0.08),
            blurRadius: _pressed ? 10 : 6,
            offset: Offset(0, _pressed ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: canTap ? widget.onTap : null,
          onTapDown: canTap ? (_) => setState(() => _pressed = true) : null,
          onTapUp: canTap ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: canTap ? () => setState(() => _pressed = false) : null,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Row(
              children: [
                widget.leading ??
                    Icon(
                      widget.emptyIcon,
                      color: AppColor.textSecondary,
                      size: 22.sp,
                    ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    _hasValue ? widget.valueText! : widget.hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.body.copyWith(
                      color: _hasValue ? AppColor.textPrimary : AppColor.textSecondary,
                      fontWeight: _hasValue ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: AppColor.textSecondary, size: 26.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
