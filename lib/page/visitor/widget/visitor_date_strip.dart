import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../visitor_provider.dart';

/// Center date label + prev/next + calendar (Android `calendarRelativeLayout`).
class VisitorDateStrip extends ConsumerWidget {
  const VisitorDateStrip({
    super.key,
    required this.selectedDay,
    required this.onPickDate,
  });

  final DateTime selectedDay;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isToday = _sameDay(selectedDay, now);
    final label = isToday ? 'Today' : DateFormat('dd MMM yyyy').format(selectedDay);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
          children: [
            _ArrowTap(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => ref.read(visitorProvider.notifier).previousDay(),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: onPickDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      child: Text(
                        label,
                        style: AppTextStyle.subtitle.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (!isToday)
                    TextButton(
                      onPressed: () {
                        final t = DateTime.now();
                        ref.read(visitorProvider.notifier).setDay(
                              DateTime(t.year, t.month, t.day),
                            );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Jump to today',
                        style: AppTextStyle.bodyMuted.copyWith(
                          fontSize: 11.sp,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _ArrowTap(
              icon: Icons.arrow_forward_ios_rounded,
              onTap: () => ref.read(visitorProvider.notifier).nextDay(),
            ),
          ],
        ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _ArrowTap extends StatelessWidget {
  const _ArrowTap({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(icon, size: 18.sp, color: AppColor.primary),
        ),
      ),
    );
  }
}
