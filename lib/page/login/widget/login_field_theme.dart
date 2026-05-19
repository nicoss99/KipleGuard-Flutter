import 'package:flutter/material.dart';

import '../../../theme/app_color.dart';

/// Splash, selection handles, and cursor colors for login inputs.
abstract final class LoginFieldTheme {
  static Widget wrap({
    required BuildContext context,
    required bool focused,
    required Widget child,
  }) {
    const cursor = AppColor.white;
    final selection = AppColor.white.withValues(alpha: 0.35);
    const handle = AppColor.white;

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: AppColor.white.withValues(alpha: 0.28),
        highlightColor: AppColor.white.withValues(alpha: 0.18),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: cursor,
          selectionColor: selection,
          selectionHandleColor: handle,
        ),
      ),
      child: child,
    );
  }
}
