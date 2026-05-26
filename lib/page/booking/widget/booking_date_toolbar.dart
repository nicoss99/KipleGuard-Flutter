import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../../visitor/widget/visitor_calendar_button.dart';
import '../booking_state.dart';
import 'booking_date_strip.dart';

class BookingDateToolbar extends StatelessWidget {
  const BookingDateToolbar({
    super.key,
    required this.state,
    required this.onPickDate,
  });

  final BookingListState state;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.sm, 6.h, AppSpacing.sm, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: BookingDateStrip(
                  selectedDay: state.selectedDay,
                  onPickDate: onPickDate,
                ),
              ),
              VisitorCalendarButton(onTap: onPickDate),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Container(height: 10.h, color: AppColor.grey),
      ],
    );
  }
}
