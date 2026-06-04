import 'package:flutter_test/flutter_test.dart';
import 'package:kiple_guard_flutter/core/guard_time_format.dart';
import 'package:kiple_guard_flutter/page/attendance/attendance_record_format.dart';

void main() {
  group('AttendanceRecordFormat.timeLabel', () {
    test('uses wall clock from +08:00 API string (12h)', () {
      const raw = '2026-05-25T22:36:11+08:00';
      final label = AttendanceRecordFormat.timeLabel(raw);
      expect(label, _expected(DateTime(2026, 5, 25, 22, 36, 11)));
      expect(label.toLowerCase(), contains('10:36 pm'));
    });

    test('uses wall clock from Z API string (12h)', () {
      const raw = '2026-05-26T14:45:00Z';
      final label = AttendanceRecordFormat.timeLabel(raw);
      expect(label, _expected(DateTime(2026, 5, 26, 14, 45, 0)));
      expect(label.toLowerCase(), contains('2:45 pm'));
    });

    test('parses ISO without seconds (12h)', () {
      const raw = '2026-05-26T14:45Z';
      final label = AttendanceRecordFormat.timeLabel(raw);
      expect(label.toLowerCase(), contains('2:45 pm'));
    });

    test('passes through legacy 12h label', () {
      const raw = 'Wed 25 May 2026, 10:36 pm';
      expect(AttendanceRecordFormat.timeLabel(raw), raw);
    });
  });
}

String _expected(DateTime myt) =>
    GuardTimeFormat.format12h(myt, GuardTimeFormat.displayDateTime);
