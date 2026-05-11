import 'register_models.dart';

/// Android `CreateVisitActivity` weekday token (`MON` … `SUN`).
String weekdayTokenFor(DateTime d) {
  const keys = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  return keys[d.weekday - 1];
}

/// `is_allow_days` + `allow_days` contains current weekday token.
bool isVisitorTypeAllowedOnDate(RegisterVisitorTypeOption type, DateTime date) {
  if (!type.isAllowDays) return true;
  final raw = type.allowDays?.trim() ?? '';
  if (raw.isEmpty) return true;
  final token = weekdayTokenFor(date);
  return raw.toUpperCase().contains(token);
}

/// Mirrors Android `CreateVisitActivity.setEndTime` using [startUtc] as base.
DateTime? computeDefaultEndUtc({
  required RegisterVisitorTypeOption type,
  required DateTime startUtc,
}) {
  final mb = type.mustLeaveBefore?.trim();
  if (mb != null && mb.isNotEmpty) {
    final dayAdd = type.mustLeaveBeforeDay ?? 0;
    final base = DateTime.utc(startUtc.year, startUtc.month, startUtc.day);
    final shifted = base.add(Duration(days: dayAdd));
    final parts = mb.split(':');
    final h = int.tryParse(parts.elementAt(0)) ?? 23;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 59 : 59;
    final s = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    return DateTime.utc(shifted.year, shifted.month, shifted.day, h, m, s);
  }
  final dayAdd = type.mustLeaveBeforeDay ?? 0;
  final hours = type.mustLeaveIn ?? 0;
  final mins = type.mustLeaveInMin ?? 0;
  if (dayAdd == 0 && hours == 0 && mins == 0) return null;
  return startUtc
      .toUtc()
      .add(Duration(days: dayAdd, hours: hours, minutes: mins));
}
