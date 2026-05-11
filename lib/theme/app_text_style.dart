import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

/// Manrope-based typography — use from [build] after [ScreenUtilInit].
abstract final class AppTextStyle {
  static TextStyle get title => GoogleFonts.manrope(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.textPrimary,
  );

  static TextStyle get subtitle => GoogleFonts.manrope(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColor.textPrimary,
  );

  static TextStyle get body => GoogleFonts.manrope(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColor.textPrimary,
  );

  static TextStyle get bodyMuted => GoogleFonts.manrope(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColor.textSecondary,
  );

  static TextStyle get counter => GoogleFonts.manrope(
    fontSize: 48.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.primary,
  );
}
