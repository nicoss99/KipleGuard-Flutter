import 'package:flutter/material.dart';

Future<DateTime?> pickVisitUtcFromSheet(
  BuildContext context, {
  required DateTime initialUtc,
}) async {
  final local = initialUtc.toLocal();
  final d = await showDatePicker(
    context: context,
    initialDate: local,
    firstDate: DateTime(local.year - 1),
    lastDate: DateTime(local.year + 2),
  );
  if (d == null || !context.mounted) return null;
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(local),
  );
  if (t == null || !context.mounted) return null;
  final combined = DateTime(d.year, d.month, d.day, t.hour, t.minute);
  return combined.toUtc();
}

String formatVisitDisplayUtc(DateTime utc) {
  final l = utc.toLocal();
  return '${l.year}-${_pad2(l.month)}-${_pad2(l.day)} ${_pad2(l.hour)}:${_pad2(l.minute)}';
}

String _pad2(int n) => n.toString().padLeft(2, '0');
