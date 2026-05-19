import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../page/attendance/attendance_provider.dart';
import '../page/booking/booking_provider.dart';
import '../page/unit_call/recent/call_recent_provider.dart';
import '../page/unit_call/unit_call_provider.dart';
import '../page/visitor/visitor_provider.dart';

/// Drops cached feature state so the next open uses [DashboardPrefs] for the new site.
void invalidateSiteScopedProviders(Ref ref) {
  ref.invalidate(visitorProvider);
  ref.invalidate(attendanceProvider);
  ref.invalidate(bookingListProvider);
  ref.invalidate(unitCallProvider);
  ref.invalidate(callRecentProvider);
}
