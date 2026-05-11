import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_color.dart';

abstract final class SelectSiteTextStyle {
  static TextStyle appBarTitle() => GoogleFonts.manrope(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: AppColor.textPrimary,
  );

  static TextStyle bannerTitle() => GoogleFonts.manrope(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: AppColor.white,
  );
}
