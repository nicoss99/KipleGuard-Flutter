/// Android `VisitorActivity.totalCheckin` / `totalOvertime` filter bodies.
String visitorCheckInFilter({
  required String residenceClause,
  required String dateStartUtc,
  required String dateEndUtc,
}) {
  return '($residenceClause '
      "AND (status='VALID') "
      "AND (latest_scan_type='IN') "
      "AND (start_time <= '$dateEndUtc') "
      'AND (end_time IS NULL OR end_time > NOW()) '
      'AND (deleted_at is NULL) '
      ')';
}

String visitorOvertimeFilter({required String residenceClause}) {
  return '($residenceClause '
      "AND (status='VALID') "
      "AND (latest_scan_type='IN') "
      'AND (end_time < NOW()) '
      'AND (deleted_at is NULL) '
      ')';
}

/// Android `VisitorActivity.totalOvertime` path for "All Overtime" section.
String visitorAllOvertimeFilter({required String residenceClause}) {
  return '($residenceClause '
      "AND (status='VALID') "
      "AND (latest_scan_type='IN') "
      'AND (end_time < NOW()) '
      'AND (deleted_at is NULL) '
      ')';
}

/// Local calendar day → UTC `yyyy-MM-dd HH:mm:ss` window (Android `updateVisitor` range).
({String start, String end}) dayBoundsUtc(DateTime localDay) {
  final startLocal = DateTime(localDay.year, localDay.month, localDay.day);
  final endLocal = DateTime(localDay.year, localDay.month, localDay.day, 23, 59, 59);
  return (start: _fmtUtc(startLocal.toUtc()), end: _fmtUtc(endLocal.toUtc()));
}

String _fmtUtc(DateTime u) {
  return '${u.year}-${_pad2(u.month)}-${_pad2(u.day)} ${_pad2(u.hour)}:${_pad2(u.minute)}:${_pad2(u.second)}';
}

String _pad2(int n) => n.toString().padLeft(2, '0');
