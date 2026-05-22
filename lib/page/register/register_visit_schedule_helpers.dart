import 'package:flutter/material.dart';

import '../../widget/app_calendar_picker.dart';

Future<DateTime?> pickVisitUtcFromSheet(
  BuildContext context, {
  required DateTime initialUtc,
}) async {
  final local = initialUtc.toLocal();
  final combined = await AppCalendarPicker.showDayAndTime(
    context: context,
    initial: local,
    lastDate: DateTime(local.year + 2, 12, 31),
  );
  return combined?.toUtc();
}

String formatVisitDisplayUtc(DateTime utc) {
  final l = utc.toLocal();
  return '${l.year}-${_pad2(l.month)}-${_pad2(l.day)} ${_pad2(l.hour)}:${_pad2(l.minute)}';
}

String _pad2(int n) => n.toString().padLeft(2, '0');
