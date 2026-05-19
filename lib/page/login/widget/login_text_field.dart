import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import 'login_field_theme.dart';
import 'login_input_box.dart';
import 'login_scaffold.dart';

/// Login text input with animated shell, compact hints, and focus-aware colors.
class LoginTextField extends StatefulWidget {
  const LoginTextField({
    super.key,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onSubmitted,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  void _onTextChange() => setState(() {});

  bool get _showHint =>
      widget.hint != null && widget.hint!.isNotEmpty && widget.controller.text.isEmpty;

  InputDecoration _decoration(BuildContext context, bool focused) {
    return InputDecoration(
      isDense: true,
      isCollapsed: true,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      hintText: _showHint ? widget.hint : null,
      hintStyle: LoginScaffold.fieldHintStyle(context, active: focused),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      suffixIcon: widget.suffixIcon == null
          ? null
          : IconTheme(
              data: const IconThemeData(color: AppColor.white, size: 22),
              child: widget.suffixIcon!,
            ),
      suffixIconConstraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    return LoginFieldTheme.wrap(
      context: context,
      focused: focused,
      child: LoginInputBox(
        active: focused,
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText,
          autocorrect: false,
          enableSuggestions: false,
          maxLines: 1,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          style: LoginScaffold.fieldTextStyle(context, active: focused),
          onSubmitted: widget.onSubmitted,
          decoration: _decoration(context, focused),
        ),
      ),
    );
  }
}
