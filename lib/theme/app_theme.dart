import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      primary: AppColor.primary,
      onPrimary: AppColor.onPrimary,
      secondary: AppColor.accent,
      surface: AppColor.white,
      onSurface: AppColor.textPrimary,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColor.white,
    );
    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: AppColor.textPrimary,
        displayColor: AppColor.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.white,
        foregroundColor: AppColor.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColor.primary,
        circularTrackColor: Color(0x24283A85),
        linearTrackColor: Color(0x24283A85),
      ),
    );
  }
}
