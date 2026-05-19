import 'package:flutter/material.dart';

/// Design tokens aligned with Android `res/values/colors.xml`.
abstract final class AppColor {
  static const Color primary = Color(0xFF283A85);
  static const Color primaryDark = Color(0xFF1E2D63);

  /// Login screen background (matches [primary]).
  static const Color loginScreenBlue = Color(0xFF283A85);
  static const Color loginScreenBlueDeep = Color(0xFF1E2D63);
  static const Color accent = Color(0xFF0CB0DB);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F7);
  static const Color white = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF414042);
  static const Color black = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF9B9B9B);
  static const Color textMuted = Color(0xFF4A4A4A);

  static const Color red = Color(0xFFEF4050);
  static const Color orange = Color(0xFFF7941D);
  static const Color green = Color(0xFF99CA44);
  static const Color grey = Color(0xFFF2F2F2);
  static const Color greyBorder = Color(0xFFCBCBCB);
  static const Color lightGreyBar = Color(0xFFF7F7F7);

  /// Android residence picker rows (`adapter_residence` grey bars).
  static const Color siteListRowGrey = Color(0xFFC4C4C4);

  /// Selected site card outline.
  static const Color siteSelectedBorder = Color(0xFF999999);
}
