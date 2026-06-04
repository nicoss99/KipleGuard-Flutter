import '../../core/guard_api_time_display.dart';

/// Guard attendance API timestamps → Malaysia display (24-hour).
abstract final class AttendanceRecordFormat {
  static String timeLabel(String? raw) => GuardApiTimeDisplay.format(raw);
}
