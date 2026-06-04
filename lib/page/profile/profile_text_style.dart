import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

/// Profile screens — same scale as [AppTextStyle] (18 / 16 / 14 .sp).
abstract final class ProfileTextStyle {
  static TextStyle get sectionHeader => AppTextStyle.body.copyWith(letterSpacing: 0.5);

  /// Menu row label — regular weight (What's New, Offline data, …).
  static TextStyle get menuRowLabel => AppTextStyle.body;

  /// Bold menu row label — Change Password only.
  static TextStyle get rowLabel => GoogleFonts.manrope(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: AppColor.textPrimary,
      );

  /// Read-only field label (Name, Email, …) — regular weight.
  static TextStyle get rowFieldLabel => AppTextStyle.body;

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
