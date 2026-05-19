import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import 'attendance_day_cell.dart';

const double _kStripCellLogical = 50;
const double _kStripGapLogical = 8;

/// Horizontal days of month (Android `calenderRecyclerView`).
class AttendanceDayStrip extends StatefulWidget {
  const AttendanceDayStrip({
    super.key,
    required this.monthDate,
    required this.selectedDay,
    required this.onSelectDay,
  });

  final DateTime monthDate;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectDay;

  @override
  State<AttendanceDayStrip> createState() => _AttendanceDayStripState();
}

class _AttendanceDayStripState extends State<AttendanceDayStrip> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(AttendanceDayStrip old) {
    super.didUpdateWidget(old);
    if (old.selectedDay != widget.selectedDay || old.monthDate != widget.monthDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _scrollToSelected() {
    if (!mounted || !_scroll.hasClients) return;
    final sameMonth =
        widget.monthDate.year == widget.selectedDay.year &&
        widget.monthDate.month == widget.selectedDay.month;
    if (!sameMonth) return;
    final index = widget.selectedDay.day - 1;
    final cell = _kStripCellLogical.w + _kStripGapLogical.w;
    final vp = _scroll.position.viewportDimension;
    final target = (index * cell) - (vp / 2) + (_kStripCellLogical.w / 2);
    _scroll.animateTo(
      target.clamp(0.0, _scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = DateTime(widget.monthDate.year, widget.monthDate.month + 1, 0);
    final days = last.day;
    final today = DateTime.now();
    final cellW = _kStripCellLogical.w;

    return ColoredBox(
      color: AppColor.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 12.h),
        child: SizedBox(
          height: 70.h,
          child: ListView.separated(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
            itemCount: days,
            separatorBuilder: (_, _) => SizedBox(width: _kStripGapLogical.w),
            itemBuilder: (ctx, i) {
              final d = DateTime(widget.monthDate.year, widget.monthDate.month, i + 1);
              final sel =
                  d.year == widget.selectedDay.year &&
                  d.month == widget.selectedDay.month &&
                  d.day == widget.selectedDay.day;
              final isToday =
                  d.year == today.year && d.month == today.month && d.day == today.day;

              return AttendanceDayCell(
                width: cellW,
                day: '${d.day}',
                selected: sel,
                isToday: isToday,
                onTap: () => widget.onSelectDay(d),
              );
            },
          ),
        ),
      ),
    );
  }
}
