import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/region_location_permission.dart';
import '../../../theme/app_color.dart';
import 'login_field_theme.dart';
import 'login_input_box.dart';
import 'login_region_data.dart';
import 'login_region_flag.dart';
import 'login_region_sheet.dart';
import '../login_strings.dart';
import 'login_scaffold.dart';

/// Region selector — flag icon + bottom sheet.
class LoginRegionField extends StatefulWidget {
  const LoginRegionField({
    super.key,
    required this.value,
    required this.onChanged,
    this.onClearError,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onClearError;

  @override
  State<LoginRegionField> createState() => _LoginRegionFieldState();
}

class _LoginRegionFieldState extends State<LoginRegionField> {
  var _pressed = false;

  bool get _active => _pressed || (widget.value != null && widget.value!.isNotEmpty);

  LoginRegionOption? get _selected => loginRegionByCode(widget.value);

  Future<void> _openSheet() async {
    unawaited(requestLocationForRegionField());
    final picked = await showLoginRegionSheet(context, selectedCode: widget.value);
    if (!mounted || picked == null) return;
    widget.onChanged(picked);
    widget.onClearError?.call();
  }

  @override
  Widget build(BuildContext context) {
    final active = _active;
    const iconColor = AppColor.white;
    final selected = _selected;

    return LoginFieldTheme.wrap(
      context: context,
      focused: active,
      child: LoginInputBox(
        active: active,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openSheet,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  if (selected != null)
                    LoginRegionFlag(code: selected.code, size: 20.w)
                  else
                    Icon(Icons.public_outlined, color: iconColor, size: 22.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      selected?.name ?? LoginStrings.regionPlaceholder,
                      textAlign: TextAlign.start,
                      style: selected == null
                          ? LoginScaffold.fieldHintStyle(context, active: active)
                          : LoginScaffold.fieldTextStyle(context, active: active),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: iconColor, size: 26.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
