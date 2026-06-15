import 'package:flutter_test/flutter_test.dart';
import 'package:kiple_guard_flutter/page/booking/booking_parsers.dart';

void main() {
  const sampleData = <String, dynamic>{
    'date': '2026-05-06',
    'tab': 'all_bookings',
    'counts': <String, dynamic>{
      'all_bookings': 1,
      'checked_in': 0,
      'upcoming': 0,
    },
    'bookings': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1083,
        'booking_number': 'BKG1083',
        'pass_code': 'BKG1083',
        'name': 'Guest',
        'mobile_number': '60987654321',
        'unit': <String, dynamic>{
          'display_label': 'New-1-9',
        },
        'category': 'hot desk 2',
        'booking_name': 'hot desk 2 booking',
        'status': 'pending',
        'guard_status': 'checked_out',
        'time_range_label': '06 May 2026, 08:00 AM to 06 May 2026, 09:00 AM',
        'duration_label': '1 hour',
        'eta_arrival_label': '06 May 2026, 08:00 AM',
        'eta_exit_label': '06 May 2026, 09:00 AM',
        'submitted_date': '2026-05-06',
        'samenity_id': 40,
      },
    ],
  };

  test('parseBookingListFromApi accepts unwrapped data payload', () {
    final result = parseBookingListFromApi(sampleData);

    expect(result.date, '2026-05-06');
    expect(result.tab, 'all_bookings');
    expect(result.counts.allBookings, 1);
    expect(result.bookings, hasLength(1));

    final row = result.bookings.first;
    expect(row.id, 1083);
    expect(row.unitLabel, 'New-1-9');
    expect(row.guardStatus, 'checked_out');
    expect(row.samenityId, 40);
    expect(row.qrCodeData, 'BKG1083');
    expect(row.timeRangeLabel, contains('08:00 AM'));
  });

  test('parseBookingListFromApi accepts full success envelope', () {
    final result = parseBookingListFromApi(<String, dynamic>{
      'success': true,
      'message': 'Success.',
      'data': sampleData,
    });

    expect(result.bookings, hasLength(1));
    expect(result.counts.checkedIn, 0);
  });

  test('parseBookingFiltersFromApi reads statuses and facilities', () {
    final filters = parseBookingFiltersFromApi(<String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'statuses': <Map<String, dynamic>>[
          <String, dynamic>{'label': 'All Bookings', 'value': 'all_bookings'},
        ],
        'facilities': <Map<String, dynamic>>[
          <String, dynamic>{'label': 'hot desk 1', 'value': 32},
          <String, dynamic>{'label': 'pool', 'samenity_id': 9},
        ],
      },
    });

    expect(filters.statuses, hasLength(1));
    expect(filters.statuses.first.value, 'all_bookings');
    expect(filters.facilities, hasLength(2));
    expect(filters.facilities.first.id, 32);
    expect(filters.facilities.first.label, 'hot desk 1');
    expect(filters.facilities.last.id, 9);
  });
}
