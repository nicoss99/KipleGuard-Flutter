import 'package:intl/intl.dart';

/// Guard attendance multipart `current_time` (e.g. `2026-05-25 12:30 PM`).
abstract final class GuardTimeFormat {
  static final _shiftTime = DateFormat('yyyy-MM-dd h:mm a');
  static final _apiDate = DateFormat('yyyy-MM-dd');

  static String shiftTimestamp(DateTime local) => _shiftTime.format(local);

  static String apiDate(DateTime local) => _apiDate.format(local);
}
