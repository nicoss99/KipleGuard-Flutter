import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_color.dart';

/// Typography for login screen (reference UI uses serif-style labels).
abstract final class LoginTheme {
  static TextStyle label(BuildContext context) => GoogleFonts.notoSerif(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColor.white,
      );

  static TextStyle fieldText(BuildContext context) => GoogleFonts.notoSerif(
        fontSize: 16.sp,
        color: AppColor.white,
      );

  static TextStyle buttonLabel(BuildContext context) => GoogleFonts.notoSerif(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.loginScreenBlue,
      );

  static TextStyle link(BuildContext context) => GoogleFonts.notoSerif(
        fontSize: 14.sp,
        color: AppColor.white,
        decoration: TextDecoration.underline,
        decorationColor: AppColor.white,
      );

  static TextStyle error(BuildContext context) => GoogleFonts.notoSerif(
        fontSize: 14.sp,
        color: AppColor.red,
      );
}
