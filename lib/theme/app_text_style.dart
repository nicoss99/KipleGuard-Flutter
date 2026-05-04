import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

/// Poppins-based typography — use from [build] after [ScreenUtilInit].
abstract final class AppTextStyle {
  static TextStyle get title => GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.textPrimary,
  );

  static TextStyle get subtitle => GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColor.textPrimary,
  );

  static TextStyle get body => GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColor.textPrimary,
  );

  static TextStyle get bodyMuted => GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColor.textSecondary,
  );

  static TextStyle get counter => GoogleFonts.poppins(
    fontSize: 48.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.primary,
  );
}
