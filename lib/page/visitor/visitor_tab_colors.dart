import 'package:flutter/material.dart';

import '../../theme/app_color.dart';
import 'visitor_model.dart';

/// Accent colors for visitor summary tabs and list stripes (Android `activity_visitor.xml`).
abstract final class VisitorTabColors {
  static Color stripeForTab(int tabIndex) => switch (tabIndex) {
        0 => AppColor.green,
        1 => AppColor.orange,
        2 => AppColor.red,
        3 => AppColor.black,
        4 => AppColor.textMuted,
        _ => AppColor.primary,
      };

  static Color stripeForCategory(VisitorListCategory category) => switch (category) {
        VisitorListCategory.checkedIn => AppColor.green,
        VisitorListCategory.upcoming => AppColor.orange,
        VisitorListCategory.overtime => AppColor.red,
      };

  /// Single-tab lists use tab color; Visitor(s) tab uses per-row category (Android `VisitorAdapter`).
  static Color stripeForItem({required int tabIndex, required VisitorListCategory category}) {
    if (tabIndex == 3) return stripeForCategory(category);
    return stripeForTab(tabIndex);
  }

}
