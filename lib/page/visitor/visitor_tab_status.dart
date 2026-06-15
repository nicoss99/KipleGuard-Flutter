import '../auth/guard_visitor_status.dart';

/// Visitor summary tabs — `GET .../visitors` query `status` + optional `date`.
abstract final class VisitorTabStatus {
  static const tabCheckedIn = 0;
  static const tabUpcoming = 1;
  static const tabOvertime = 2;
  static const tabAllVisitors = 3;
  static const tabCheckedOut = 4;

  /// `null` = Visitor(s) tab (no status query param).
  static String? apiStatusForTab(int tab) => switch (tab) {
        tabCheckedIn => GuardVisitorApiStatus.checkedIn,
        tabUpcoming => GuardVisitorApiStatus.upcoming,
        tabOvertime => GuardVisitorApiStatus.overtime,
        tabCheckedOut => GuardVisitorApiStatus.checkedOut,
        tabAllVisitors => null,
        _ => null,
      };

  static bool usesAllApiStatuses(int tab) => tab == tabAllVisitors;

  static String cacheKeyForTab(int tab) => switch (tab) {
        tabCheckedIn => GuardVisitorApiStatus.checkedIn,
        tabUpcoming => GuardVisitorApiStatus.upcoming,
        tabOvertime => GuardVisitorApiStatus.overtime,
        tabCheckedOut => GuardVisitorApiStatus.checkedOut,
        tabAllVisitors => 'all',
        _ => 'all',
      };

  static const allOvertimeCacheKey = 'all_overtime';
}
