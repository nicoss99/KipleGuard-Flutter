import 'package:intl/intl.dart';

/// Guard app time formatting — API payloads and UI (12-hour clock).
abstract final class GuardTimeFormat {
  static final _shiftTime = DateFormat('yyyy-MM-dd h:mm a', 'en_US');
  static final _apiDate = DateFormat('yyyy-MM-dd');

  static final displayDateTime = DateFormat('EEE dd MMM yyyy, hh:mm a', 'en_US');

  static final displayTime = DateFormat('hh:mm a', 'en_US');

  static final displayDateTimeMedium = DateFormat('dd MMM yyyy, hh:mm a', 'en_US');

  static final displayDateTimeDot = DateFormat('dd MMM yyyy · hh:mm a', 'en_US');

  static final displayDateTimePicker = DateFormat('dd MMM yyyy - hh:mm a', 'en_US');

  static final displayDateOnly = DateFormat('dd MMM yyyy', 'en_US');

  static final displaySavedAt = DateFormat('d MMM yyyy, hh:mm a', 'en_US');

  static final apiDateTime = DateFormat('yyyy-MM-dd hh:mm a', 'en_US');

  static final apiDateTimeSeconds = DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US');

  /// Formats with lowercase am/pm (e.g. `2:45 pm`).
  static String format12h(DateTime dt, DateFormat pattern) =>
      pattern.format(dt).replaceAllMapped(
        RegExp(r'\b(AM|PM)\b'),
        (m) => m.group(0)!.toLowerCase(),
      );

  /// Multipart `current_time` for start/end shift.
  static String shiftTimestamp(DateTime local) => format12h(local, _shiftTime);

  static String formatApiDate(DateTime local) => _apiDate.format(local);

  static String formatVisitPicker(DateTime local) =>
      '${_apiDate.format(local)} ${format12h(local, displayTime)}';
}
