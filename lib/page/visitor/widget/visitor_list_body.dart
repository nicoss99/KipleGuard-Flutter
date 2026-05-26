import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../router/app_route.dart' show AppPaths;
import '../../../theme/app_color.dart';
import '../../auth/guard_visitor_status.dart';
import '../visitor_provider.dart';
import '../visitor_state.dart';
import '../visitor_tab_colors.dart';
import 'visitor_empty_state.dart';
import 'visitor_list_footer.dart';
import 'visitor_list_tile.dart';

class VisitorListBody extends ConsumerWidget {
  const VisitorListBody({super.key, required this.state});

  final VisitorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColor.primary,
      onRefresh: () => ref.read(visitorProvider.notifier).refresh(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is! ScrollEndNotification) return false;
          final metrics = notification.metrics;
          if (metrics.axis != Axis.vertical || metrics.pixels <= 0 || metrics.extentAfter != 0) {
            return false;
          }
          ref.read(visitorProvider.notifier).loadMore();
          return false;
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
              child: child,
            ),
          ),
          child: state.items.isEmpty
              ? ListView(
                  key: ValueKey('empty_${state.tabIndex}_${state.selectedDay.toIso8601String()}'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 24.h),
                    const VisitorEmptyState(),
                  ],
                )
              : ListView.separated(
                  key: ValueKey('list_${state.tabIndex}_${state.selectedDay.toIso8601String()}'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
                  itemCount: state.items.length + 1,
                  separatorBuilder: (_, _) => SizedBox(height: 4.h),
                  itemBuilder: (ctx, i) {
                    if (i == state.items.length) {
                      return VisitorListFooter(state: state);
                    }
                    final row = state.items[i];
                    final isIn =
                        row.visitStatus == GuardVisitorApiStatus.checkedIn ||
                        row.latestScanType.toUpperCase() == 'IN';

                    return VisitorListTile(
                      item: row,
                      stripeColor: VisitorTabColors.stripeForItem(
                        tabIndex: state.tabIndex,
                        category: row.category,
                      ),
                      onTap: () => context.push(AppPaths.visitorDetails(row.uuid)),
                      onActionTap: () => ref.read(visitorProvider.notifier).quickAction(row),
                      actionLabel: isIn ? 'Out' : 'In',
                      isCheckedIn: isIn,
                    );
                  },
                ),
        ),
      ),
    );
  }
}
