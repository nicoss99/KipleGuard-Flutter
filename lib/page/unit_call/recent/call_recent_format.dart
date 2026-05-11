import 'package:intl/intl.dart';

/// Android `VoipCallHistoryAdapter`: input GMT `yyyy-MM-dd HH:mm:ss`.
DateTime? parseCallAtGmt(String raw) {
  try {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(raw, true);
  } catch (_) {
    return null;
  }
}

String formatRecentDateLabel(DateTime local) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(local.year, local.month, local.day);
  if (d == today) return 'Today';
  final yest = today.subtract(const Duration(days: 1));
  if (d == yest) return 'Yesterday';
  return DateFormat('dd MMM yyyy').format(local);
}

String formatRecentTime(DateTime local) {
  return DateFormat('hh:mm a').format(local).toLowerCase();
}
