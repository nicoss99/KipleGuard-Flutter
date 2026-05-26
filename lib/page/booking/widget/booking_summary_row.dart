import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../visitor/visitor_text_style.dart';
import '../booking_provider.dart';
import '../booking_state.dart';
import '../booking_strings.dart';
import '../booking_tab_colors.dart';

class BookingSummaryRow extends ConsumerWidget {
  const BookingSummaryRow({super.key, required this.state});

  final BookingListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 2.h, AppSpacing.md, 8.h),
      child: Row(
        children: [
          _StatCard(
            label: BookingStrings.tabAllBookings,
            count: state.totalAllBookings,
            accent: BookingTabColors.stripeForTab(BookingTab.allBookings),
            selected: state.tab == BookingTab.allBookings,
            onTap: () => ref.read(bookingListProvider.notifier).setTab(BookingTab.allBookings),
          ),
          SizedBox(width: 8.w),
          _StatCard(
            label: BookingStrings.tabCheckedIn,
            count: state.totalCheckedIn,
            accent: BookingTabColors.stripeForTab(BookingTab.checkedIn),
            selected: state.tab == BookingTab.checkedIn,
            onTap: () => ref.read(bookingListProvider.notifier).setTab(BookingTab.checkedIn),
          ),
          SizedBox(width: 8.w),
          _StatCard(
            label: BookingStrings.tabUpcoming,
            count: state.totalUpcoming,
            accent: BookingTabColors.stripeForTab(BookingTab.upcoming),
            selected: state.tab == BookingTab.upcoming,
            onTap: () => ref.read(bookingListProvider.notifier).setTab(BookingTab.upcoming),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.count,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int? count;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        elevation: selected ? 2 : 1,
        shadowColor: AppColor.textPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: selected ? accent : AppColor.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: accent, width: selected ? 2 : 1.2),
            ),
            child: Column(
              children: [
                Text(
                  '${count ?? 0}',
                  style: VisitorTextStyle.statCount(selected: selected, accent: accent),
                ),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: VisitorTextStyle.statLabel(selected: selected),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
