import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_color.dart';

/// Dashboard typography (Manrope).
abstract final class DashboardTextStyle {
  static TextStyle headerTitle() => GoogleFonts.manrope(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: AppColor.textPrimary,
  );

  static TextStyle tileTitle({required bool enabled}) => GoogleFonts.manrope(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    color: enabled ? AppColor.textPrimary : AppColor.textSecondary,
  );

  static TextStyle tileSubtitle({required bool enabled}) => GoogleFonts.manrope(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColor.textSecondary.withValues(alpha: enabled ? 1 : 0.75),
  );

  static TextStyle heroPillGreeting() => GoogleFonts.manrope(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.white,
  );

  static TextStyle heroEmail() => GoogleFonts.manrope(
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    color: AppColor.white.withValues(alpha: 0.95),
  );

  static TextStyle heroInitials() => GoogleFonts.manrope(
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    color: AppColor.primary,
  );

  static TextStyle bottomLabel(Color color) => GoogleFonts.manrope(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );
}
