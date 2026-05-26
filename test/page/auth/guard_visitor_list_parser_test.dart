import 'package:flutter_test/flutter_test.dart';
import 'package:kiple_guard_flutter/page/auth/guard_visitor_day_result.dart';
import 'package:kiple_guard_flutter/page/auth/guard_visitor_list_parser.dart';

void main() {
  const sampleData = <String, dynamic>{
    'date': '2026-05-22',
    'status': 'overtime',
    'counts': <String, dynamic>{
      'all_visitors': 2,
      'overtime': 2,
      'checked_in': 0,
      'upcoming': 0,
    },
    'overtime': <Map<String, dynamic>>[
      <String, dynamic>{'id': 5243, 'name': 'Test'},
    ],
  };

  test('GuardVisitorCounts parses new count keys', () {
    final c = GuardVisitorCounts.fromJson(sampleData['counts'] as Map<String, dynamic>);
    expect(c.allVisitors, 2);
    expect(c.overtime, 2);
  });

  test('visitorListFromPayload reads status-keyed list', () {
    final list = visitorListFromPayload(sampleData, requestedStatus: 'overtime');
    expect(list, hasLength(1));
  });

  test('visitorListFromPayload reads all_visitors list', () {
    final data = Map<String, dynamic>.from(sampleData)
      ..remove('overtime')
      ..['all_visitors'] = sampleData['overtime'];
    final list = visitorListFromPayload(data);
    expect(list, hasLength(1));
  });
}
