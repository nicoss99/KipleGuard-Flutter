import 'package:flutter/material.dart';

import '../../core/guard_time_format.dart';
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

String formatVisitDisplayUtc(DateTime utc) =>
    GuardTimeFormat.formatVisitPicker(utc.toLocal());
