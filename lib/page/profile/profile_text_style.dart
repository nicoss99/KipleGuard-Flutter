import 'package:flutter/material.dart';

import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

/// Profile screens — same scale as [AppTextStyle] (18 / 16 / 14 .sp).
abstract final class ProfileTextStyle {
  static TextStyle get sectionHeader => AppTextStyle.bodyMuted.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

  /// Account / menu row label — 14.sp, primary text (same size as email row, original color).
  static TextStyle get rowLabel => AppTextStyle.body.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get rowValue => AppTextStyle.body;

  static TextStyle get rowValueMuted => AppTextStyle.bodyMuted;

  static TextStyle get avatarInitials => AppTextStyle.title.copyWith(
        color: AppColor.primary,
        fontWeight: FontWeight.w700,
      );

  /// Field labels on login-blue background (change password).
  static TextStyle get formLabelOnBlue => AppTextStyle.body.copyWith(
        color: AppColor.white,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get formError => AppTextStyle.body.copyWith(color: AppColor.red);

  static TextStyle get version => AppTextStyle.bodyMuted;

  static TextStyle get headerAction => AppTextStyle.subtitle.copyWith(color: AppColor.primary);
}
