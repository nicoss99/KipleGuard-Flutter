import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_color.dart';

/// Dashboard typography from reference UI: **serif** titles, **sans** subtitles.
abstract final class DashboardTextStyle {
  static TextStyle headerTitle() => GoogleFonts.merriweather(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: AppColor.textPrimary,
  );

  static TextStyle tileTitle({required bool enabled}) => GoogleFonts.merriweather(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    color: enabled ? AppColor.textPrimary : AppColor.textSecondary,
  );

  static TextStyle tileSubtitle({required bool enabled}) => GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColor.textSecondary.withValues(alpha: enabled ? 1 : 0.75),
  );

  static TextStyle heroPillGreeting() => GoogleFonts.poppins(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.white,
  );

  static TextStyle heroEmail() => GoogleFonts.poppins(
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    color: AppColor.white.withValues(alpha: 0.95),
  );

  static TextStyle heroInitials() => GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    color: AppColor.primary,
  );

  static TextStyle bottomLabel(Color color) => GoogleFonts.poppins(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );
}
