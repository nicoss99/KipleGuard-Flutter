/// Query `status` values for `GET .../visitors`.
abstract final class GuardVisitorApiStatus {
  static const upcoming = 'upcoming';
  static const checkedIn = 'checked_in';
  static const overtime = 'overtime';

  /// Legacy per-record statuses (detail / scan).
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const checkedOut = 'checked_out';
}
