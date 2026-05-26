/// `GET .../visitors` — `data.counts` + status-keyed visitor list.
class GuardVisitorCounts {
  const GuardVisitorCounts({
    this.allVisitors = 0,
    this.overtime = 0,
    this.checkedIn = 0,
    this.upcoming = 0,
  });

  final int allVisitors;
  final int overtime;
  final int checkedIn;
  final int upcoming;

  factory GuardVisitorCounts.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GuardVisitorCounts();
    int n(String key) => (json[key] as num?)?.toInt() ?? 0;
    if (json.containsKey('all_visitors') || json.containsKey('overtime')) {
      return GuardVisitorCounts(
        allVisitors: n('all_visitors'),
        overtime: n('overtime'),
        checkedIn: n('checked_in'),
        upcoming: n('upcoming'),
      );
    }
    return GuardVisitorCounts(
      allVisitors: n('pending') + n('approved') + n('rejected') + n('checked_in') + n('checked_out'),
      overtime: n('checked_out'),
      checkedIn: n('checked_in'),
      upcoming: n('pending'),
    );
  }
}
