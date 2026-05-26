/// `GET .../visitors?date=` — `data.counts` + `data.visitors`.
class GuardVisitorCounts {
  const GuardVisitorCounts({
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
    this.checkedIn = 0,
    this.checkedOut = 0,
  });

  final int pending;
  final int approved;
  final int rejected;
  final int checkedIn;
  final int checkedOut;

  int get total => pending + approved + rejected + checkedIn + checkedOut;

  factory GuardVisitorCounts.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GuardVisitorCounts();
    int n(String key) => (json[key] as num?)?.toInt() ?? 0;
    return GuardVisitorCounts(
      pending: n('pending'),
      approved: n('approved'),
      rejected: n('rejected'),
      checkedIn: n('checked_in'),
      checkedOut: n('checked_out'),
    );
  }
}
