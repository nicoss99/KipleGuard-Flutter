import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../login/login_theme.dart';
import '../../register/widget/register_underline_field.dart';

/// Password field — login label/error typography on white background.
class ProfileLoginPasswordField extends StatelessWidget {
  const ProfileLoginPasswordField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    this.errorText,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: LoginTheme.label(context).copyWith(color: AppColor.textPrimary),
        ),
        SizedBox(height: 4.h),
        RegisterUnderlineField(
          controller: controller,
          hint: hint,
          obscureText: obscure,
          suffix: IconButton(
            onPressed: onToggleObscure,
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColor.primary,
              size: 22.sp,
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 6.h),
          Text(errorText!, style: LoginTheme.error(context)),
        ],
      ],
    );
  }
}
