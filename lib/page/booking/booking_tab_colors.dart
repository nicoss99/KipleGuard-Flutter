import 'package:flutter/material.dart';

import '../../theme/app_color.dart';
import 'booking_state.dart';
import 'booking_strings.dart';

/// Accent colors for booking summary tabs and list stripes.
abstract final class BookingTabColors {
  static Color stripeForTab(BookingTab tab) => switch (tab) {
        BookingTab.allBookings => AppColor.primary,
        BookingTab.checkedIn => AppColor.green,
        BookingTab.upcoming => AppColor.orange,
      };

  static IconData iconForTab(BookingTab tab) => switch (tab) {
        BookingTab.allBookings => Icons.event_note_rounded,
        BookingTab.checkedIn => Icons.login_rounded,
        BookingTab.upcoming => Icons.schedule_rounded,
      };

  static String tabLabel(BookingTab tab) => switch (tab) {
        BookingTab.allBookings => BookingStrings.tabAllBookings,
        BookingTab.checkedIn => BookingStrings.tabCheckedIn,
        BookingTab.upcoming => BookingStrings.tabUpcoming,
      };
}
