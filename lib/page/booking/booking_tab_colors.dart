import 'package:flutter/material.dart';

import '../../theme/app_color.dart';
import 'booking_state.dart';

/// Accent colors for booking summary tabs and list stripes.
abstract final class BookingTabColors {
  static Color stripeForTab(BookingTab tab) => switch (tab) {
        BookingTab.allBookings => AppColor.primary,
        BookingTab.checkedIn => AppColor.green,
        BookingTab.upcoming => AppColor.orange,
      };

}
