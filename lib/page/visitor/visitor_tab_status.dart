import '../auth/guard_visitor_status.dart';

/// Visitor summary tabs — filter `GET .../visitors?date=` by `data.visitors[].status`.
/// Counts from `data.counts`: pending, approved, rejected, checked_in, checked_out.
/// - Upcoming → pending
/// - Checked In → checked_in
/// - Overtime → checked_out
/// - Visitor(s) → all visitors in response
abstract final class VisitorTabStatus {
  static const tabCheckedIn = 0;
  static const tabUpcoming = 1;
  static const tabOvertime = 2;
  static const tabAllVisitors = 3;

  static String apiStatusForTab(int tab) => switch (tab) {
        tabCheckedIn => GuardVisitorApiStatus.checkedIn,
        tabUpcoming => GuardVisitorApiStatus.pending,
        tabOvertime => GuardVisitorApiStatus.checkedOut,
        tabAllVisitors => '',
        _ => '',
      };

  static bool usesAllApiStatuses(int tab) => tab == tabAllVisitors;
}
