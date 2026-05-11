import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';

/// Underline-style text field with focus-aware indicator (Android `EditText` + grey divider).
class RegisterUnderlineField extends StatefulWidget {
  const RegisterUnderlineField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboard,
    this.suffix,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final Widget? suffix;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  State<RegisterUnderlineField> createState() => _RegisterUnderlineFieldState();
}

class _RegisterUnderlineFieldState extends State<RegisterUnderlineField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                readOnly: widget.readOnly,
                keyboardType: widget.keyboard,
                maxLines: widget.maxLines,
                textCapitalization: widget.textCapitalization,
                inputFormatters: widget.inputFormatters,
                style: AppTextStyle.body,
                cursorColor: AppColor.primary,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppTextStyle.bodyMuted,
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
            if (widget.suffix != null)
              Padding(padding: EdgeInsets.only(left: 8.w), child: widget.suffix),
          ],
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: focused ? 1.6 : 1,
          color: focused ? AppColor.primary : AppColor.greyBorder,
        ),
      ],
    );
  }
}
