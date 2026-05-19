import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../visitor_provider.dart';
import '../visitor_state.dart';
import 'visitor_all_overtime_card.dart';
import 'visitor_calendar_button.dart';
import 'visitor_date_strip.dart';

/// Calendar row + grey separator (Android `calendarView`).
class VisitorDateToolbar extends ConsumerWidget {
  const VisitorDateToolbar({
    super.key,
    required this.state,
    required this.onPickDate,
  });

  final VisitorState state;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.sm, 6.h, AppSpacing.sm, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              VisitorAllOvertimeCard(
                selected: state.allOvertimeSection,
                onTap: () => ref.read(visitorProvider.notifier).openAllOvertimeSection(),
              ),
              Expanded(
                child: VisitorDateStrip(
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
