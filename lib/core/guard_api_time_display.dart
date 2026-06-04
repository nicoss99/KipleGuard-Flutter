import 'package:intl/intl.dart';

import 'guard_time_format.dart';
import 'guard_timezone.dart';

/// Parses guard API timestamp strings and formats for UI (MYT wall clock, 24-hour).
abstract final class GuardApiTimeDisplay {
  static final _legacyPatterns = [
    DateFormat('EEE dd MMM yyyy, hh:mm a', 'en_US'),
    DateFormat('dd MMM yyyy, hh:mm a', 'en_US'),
    DateFormat('dd MMM yyyy, h:mma', 'en_US'),
  ];

  static String format(String? raw) => _format(raw, GuardTimeFormat.displayDateTime);

  static String formatMedium(String? raw) =>
      _format(raw, GuardTimeFormat.displayDateTimeMedium);

  static String _format(String? raw, DateFormat pattern) {
    if (raw == null) return '';
    final t = raw.trim();
    if (t.isEmpty || t.toLowerCase() == 'null') return '';

    final legacy = _parseLegacy12hLabel(t);
    if (legacy != null) return pattern.format(legacy);

    final myt = _wallClockFromApi(t);
    if (myt == null) return t;

    return pattern.format(myt);
  }

  static DateTime? _parseLegacy12hLabel(String raw) {
    if (!RegExp(r'am|pm', caseSensitive: false).hasMatch(raw)) return null;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(raw)) return null;
    final normalized = raw.replaceAllMapped(
      RegExp(r'\b(am|pm)\b', caseSensitive: false),
      (m) => m.group(0)!.toUpperCase(),
    );
    for (final fmt in _legacyPatterns) {
      try {
        return fmt.parse(normalized);
      } catch (_) {}
    }
    return null;
  }

  static String _isoCore(String raw) {
    var core = raw.trim().split('.').first.replaceAll('T', ' ');
    core = core.replaceFirst(RegExp(r'[Zz]$'), '');
    core = core.replaceFirst(RegExp(r'[+-]\d{2}(:?\d{2})?$'), '');
    return core.trim();
  }

  static DateTime? _wallClockFromApi(String raw) {
    final core = _isoCore(raw);

    final withSeconds = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2}) (\d{1,2}):(\d{2}):(\d{2})$',
    ).firstMatch(core);
    if (withSeconds != null) {
      return _fromMatch(withSeconds, hasSeconds: true);
    }

    final withoutSeconds = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2}) (\d{1,2}):(\d{2})$',
    ).firstMatch(core);
    if (withoutSeconds != null) {
      return _fromMatch(withoutSeconds, hasSeconds: false);
    }

    return null;
  }

  static DateTime _fromMatch(RegExpMatch m, {required bool hasSeconds}) =>
      GuardTimezone.wallClock(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
        int.parse(m.group(4)!),
        int.parse(m.group(5)!),
        hasSeconds ? int.parse(m.group(6)!) : 0,
      );
}
