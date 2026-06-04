import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../router/app_route.dart' show AppPaths;
import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../../../widget/app_success_dialog.dart';
import '../../../widget/guard_list_empty_state.dart';
import '../../auth/guard_visitor_status.dart';
import '../visitor_provider.dart';
import '../visitor_state.dart';
import '../visitor_strings.dart';
import '../visitor_tab_colors.dart';
import 'visitor_list_footer.dart';
import 'visitor_list_tile.dart';

class VisitorListBody extends ConsumerWidget {
  const VisitorListBody({super.key, required this.state});

  final VisitorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 32.h),
          child: const GuardListEmptyState(),
        ),
      );
    }

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
        child: ListView.separated(
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
              onActionTap: () async {
                final ok = await ref.read(visitorProvider.notifier).quickAction(row);
                if (!context.mounted || !ok) return;
                await showAppSuccessDialog(
                  context,
                  message: isIn ? VisitorStrings.checkOutSuccess : VisitorStrings.checkInSuccess,
                );
              },
              actionLabel: isIn ? 'Out' : 'In',
              isCheckedIn: isIn,
            );
          },
        ),
      ),
    );
  }
}
