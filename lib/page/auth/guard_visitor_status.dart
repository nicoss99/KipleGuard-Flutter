/// Query `status` values for `GET .../visitors?date=&status=`.
abstract final class GuardVisitorApiStatus {
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const checkedIn = 'checked_in';
  static const checkedOut = 'checked_out';

  /// Every status the guard visitors API supports (no unfiltered list call).
  static const allQueryStatuses = [
    pending,
    approved,
    rejected,
    checkedIn,
    checkedOut,
  ];
}
