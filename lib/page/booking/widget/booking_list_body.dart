import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../router/app_route.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../booking_list_filters.dart';
import '../booking_provider.dart';
import '../../../widget/guard_list_empty_state.dart';
import '../booking_state.dart';
import '../booking_tab_colors.dart';
import 'booking_list_tile.dart';
import 'booking_search_empty_state.dart';

class BookingListBody extends ConsumerWidget {
  const BookingListBody({super.key, required this.state});

  final BookingListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 32.h),
          child: bookingSearchActive(state.searchQuery)
              ? BookingSearchEmptyState(query: state.searchQuery)
              : const GuardListEmptyState(),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColor.primary,
      onRefresh: () => ref.read(bookingListProvider.notifier).refresh(),
      child: ListView.separated(
        key: ValueKey(
          'list_${state.tab}_${state.selectedDay.toIso8601String()}_${state.searchQuery}',
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
        itemCount: state.items.length,
        separatorBuilder: (_, _) => SizedBox(height: 4.h),
        itemBuilder: (ctx, i) {
          final item = state.items[i];
          return BookingListTile(
            item: item,
            stripeColor: BookingTabColors.stripeForTab(state.tab),
            onTap: () => context.pushNamed(
              AppRoute.bookingDetail.name,
              pathParameters: {'bookingUuid': '${item.id}'},
            ),
          );
        },
      ),
    );
  }
}
