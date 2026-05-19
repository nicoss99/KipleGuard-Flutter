import 'package:intl/intl.dart';

/// API UTC timestamps → local display (`EEE dd MMM yyyy, hh:mm a`).
abstract final class AttendanceRecordFormat {
  static final _display = DateFormat('EEE dd MMM yyyy, hh:mm a', 'en_US');

  static String timeLabel(String? raw) {
    if (raw == null) return '';
    final t = raw.trim();
    if (t.isEmpty || t.toLowerCase() == 'null') return '';

    if (_looksPreformatted(t)) return t;

    final local = _parseApiUtcAsLocal(t);
    if (local == null) return t;

    return _display.format(local).replaceAllMapped(
      RegExp(r'\b(AM|PM)\b'),
      (m) => m.group(0)!.toLowerCase(),
    );
  }

  static bool _looksPreformatted(String raw) {
    final hasAmPm = RegExp(r'am|pm|AM|PM').hasMatch(raw);
    final looksIso = RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(raw);
    return hasAmPm && !looksIso;
  }

  static DateTime? _parseApiUtcAsLocal(String raw) {
    if (raw.endsWith('Z')) {
      try {
        return DateTime.parse(raw).toLocal();
      } catch (_) {}
    }
    if (RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(raw)) {
      try {
        return DateTime.parse(raw).toLocal();
      } catch (_) {}
    }

    final core = raw.split('.').first.replaceAll('T', ' ');
    final m = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2}) (\d{1,2}):(\d{2}):(\d{2})$',
    ).firstMatch(core);
    if (m != null) {
      return DateTime.utc(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
        int.parse(m.group(4)!),
        int.parse(m.group(5)!),
        int.parse(m.group(6)!),
      ).toLocal();
    }

    return null;
  }
}
