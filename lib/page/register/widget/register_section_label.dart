import 'package:flutter/material.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';

/// Bold section heading used across register screens (Android `textStyle="bold"` labels).
class RegisterSectionLabel extends StatelessWidget {
  const RegisterSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTextStyle.subtitle.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColor.textPrimary,
        ),
      ),
    );
  }
}
