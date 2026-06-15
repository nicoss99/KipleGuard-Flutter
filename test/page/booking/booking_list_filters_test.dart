import 'package:flutter_test/flutter_test.dart';
import 'package:kiple_guard_flutter/page/booking/booking_filter_query.dart';
import 'package:kiple_guard_flutter/page/booking/booking_list_filters.dart';
import 'package:kiple_guard_flutter/page/booking/booking_model.dart';
import 'package:kiple_guard_flutter/page/booking/booking_search_helpers.dart';
import 'package:kiple_guard_flutter/page/booking/booking_state.dart';

BookingListItem _item({
  required int id,
  String guardStatus = 'upcoming',
  String category = 'hot desk 1',
  String bookingName = 'hot desk 1 booking',
  int? samenityId,
  String submittedDate = '2026-05-06',
}) =>
    BookingListItem(
      id: id,
      bookingNumber: 'BKG$id',
      name: 'Guest',
      mobileNumber: '60123456789',
      unitLabel: 'A-1-1',
      category: category,
      bookingName: bookingName,
      guardStatus: guardStatus,
      timeRangeLabel: '08:00 AM',
      durationLabel: '1 hour',
      submittedDate: submittedDate,
      samenityId: samenityId,
    );

void main() {
  test('applyBookingListFilters keeps only selected facility by samenity id', () {
    final items = [
      _item(id: 1, samenityId: 32, category: 'hot desk 1'),
      _item(id: 2, samenityId: 40, category: 'hot desk 2'),
    ];

    final out = applyBookingListFilters(
      items: items,
      filter: const BookingFilterQuery(
        facilityId: 32,
        facilityLabel: 'hot desk 1',
      ),
    );

    expect(out, hasLength(1));
    expect(out.first.id, 1);
  });

  test('applyBookingListFilters matches facility label when row id missing', () {
    final items = [
      _item(id: 1, category: 'hot desk 1', bookingName: 'hot desk 1 booking'),
      _item(id: 2, category: 'hot desk 2', bookingName: 'hot desk 2 booking'),
    ];

    final out = applyBookingListFilters(
      items: items,
      filter: const BookingFilterQuery(
        facilityId: 32,
        facilityLabel: 'hot desk 1',
      ),
    );

    expect(out, hasLength(1));
    expect(out.first.category, 'hot desk 1');
  });

  test('applyBookingTabFilter respects checked-in tab while filters active', () {
    final items = [
      _item(id: 1, guardStatus: 'checked_in'),
      _item(id: 2, guardStatus: 'upcoming'),
    ];

    final out = applyBookingTabFilter(items, BookingTab.checkedIn);

    expect(out, hasLength(1));
    expect(out.first.id, 1);
  });
}
