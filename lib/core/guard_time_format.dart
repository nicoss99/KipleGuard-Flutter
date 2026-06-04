import 'package:intl/intl.dart';

/// Guard app time formatting — API payloads and UI (24-hour clock).
abstract final class GuardTimeFormat {
  static final _shiftTime = DateFormat('yyyy-MM-dd HH:mm');
  static final _apiDate = DateFormat('yyyy-MM-dd');

  static final displayDateTime = DateFormat('EEE dd MMM yyyy, HH:mm', 'en_US');

  static final displayTime = DateFormat('HH:mm', 'en_US');

  static final displayDateTimeMedium = DateFormat('dd MMM yyyy, HH:mm', 'en_US');

  static final displayDateTimeDot = DateFormat('dd MMM yyyy · HH:mm', 'en_US');

  static final displayDateTimePicker = DateFormat('dd MMM yyyy - HH:mm', 'en_US');

  static final displayDateOnly = DateFormat('dd MMM yyyy', 'en_US');

  static final displaySavedAt = DateFormat('d MMM yyyy, HH:mm', 'en_US');

  static final apiDateTime = DateFormat('yyyy-MM-dd HH:mm', 'en_US');

  static final apiDateTimeSeconds = DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US');

  /// Multipart `current_time` for start/end shift.
  static String shiftTimestamp(DateTime local) => _shiftTime.format(local);

  static String formatApiDate(DateTime local) => _apiDate.format(local);

  static String formatVisitPicker(DateTime local) =>
      '${_apiDate.format(local)} ${displayTime.format(local)}';
}
