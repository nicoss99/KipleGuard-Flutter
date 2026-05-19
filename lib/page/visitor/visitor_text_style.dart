import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_color.dart';

/// Visitor list typography.
abstract final class VisitorTextStyle {
  static TextStyle sectionLabel() => GoogleFonts.manrope(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.textSecondary,
        letterSpacing: 0.2,
      );

  static TextStyle statCount({required bool selected, required Color accent}) =>
      GoogleFonts.manrope(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: selected ? AppColor.white : accent,
      );

  static TextStyle statLabel({required bool selected}) => GoogleFonts.manrope(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        height: 1.15,
        color: selected ? AppColor.white.withValues(alpha: 0.92) : AppColor.textPrimary,
      );

  static TextStyle dateTitle() => GoogleFonts.manrope(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColor.textPrimary,
      );

  static TextStyle dateSubtitle() => GoogleFonts.manrope(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.textSecondary,
        letterSpacing: 0.3,
      );

  static TextStyle visitorName() => GoogleFonts.manrope(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppColor.textPrimary,
      );

  static TextStyle meta() => GoogleFonts.manrope(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColor.textMuted,
      );
}
