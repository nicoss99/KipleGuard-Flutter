import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../visitor_provider.dart';
import '../visitor_state.dart';
import '../visitor_tab_colors.dart';
import '../visitor_text_style.dart';

class VisitorSummaryRow extends ConsumerWidget {
  const VisitorSummaryRow({super.key, required this.state});

  final VisitorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 2.h, AppSpacing.md, 8.h),
      child: Row(
        children: [
          _StatCard(
            label: 'Visitor(s)',
            count: state.totalVisitors,
            accent: VisitorTabColors.stripeForTab(3),
            selected: state.tabIndex == 3,
            onTap: () => ref.read(visitorProvider.notifier).setTab(3),
          ),
          SizedBox(width: 8.w),
          _StatCard(
            label: 'Overtime',
            count: state.totalOvertime,
            accent: VisitorTabColors.stripeForTab(2),
            selected: state.tabIndex == 2,
            onTap: () => ref.read(visitorProvider.notifier).setTab(2),
          ),
          SizedBox(width: 8.w),
          _StatCard(
            label: 'Checked In',
            count: state.totalCheckIn,
            accent: VisitorTabColors.stripeForTab(0),
            selected: state.tabIndex == 0,
            onTap: () => ref.read(visitorProvider.notifier).setTab(0),
          ),
          SizedBox(width: 8.w),
          _StatCard(
            label: 'Upcoming',
            count: state.totalIncoming,
            accent: VisitorTabColors.stripeForTab(1),
            selected: state.tabIndex == 1,
            onTap: () => ref.read(visitorProvider.notifier).setTab(1),
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
