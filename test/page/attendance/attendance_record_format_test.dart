import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kiple_guard_flutter/core/guard_time_format.dart';
import 'package:kiple_guard_flutter/page/attendance/attendance_record_format.dart';

void main() {
  group('AttendanceRecordFormat.timeLabel', () {
    test('uses wall clock from +08:00 API string (24h)', () {
      const raw = '2026-05-25T22:36:11+08:00';
      final label = AttendanceRecordFormat.timeLabel(raw);
      expect(label, _expected(DateTime(2026, 5, 25, 22, 36, 11)));
      expect(label, contains('22:36'));
    });

    test('uses wall clock from Z API string (24h)', () {
      const raw = '2026-05-26T14:45:00Z';
      final label = AttendanceRecordFormat.timeLabel(raw);
      expect(label, _expected(DateTime(2026, 5, 26, 14, 45, 0)));
      expect(label, contains('14:45'));
    });

    test('parses ISO without seconds (24h)', () {
      const raw = '2026-05-26T14:45Z';
      final label = AttendanceRecordFormat.timeLabel(raw);
      expect(label, contains('14:45'));
    });

    test('converts legacy 12h cached label to 24h', () {
      const raw = 'Wed 25 May 2026, 10:36 pm';
      final label = AttendanceRecordFormat.timeLabel(raw);
      expect(label, contains('22:36'));
      expect(label.toLowerCase(), isNot(contains('pm')));
    });
  });
}

String _expected(DateTime myt) => GuardTimeFormat.displayDateTime.format(myt);
