import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../router/app_route.dart';
import '../../../theme/app_color.dart';
import '../booking_provider.dart';
import '../booking_state.dart';
import '../booking_strings.dart';
import '../booking_tab_colors.dart';
import 'booking_empty_state.dart';
import 'booking_list_tile.dart';

class BookingListBody extends ConsumerWidget {
  const BookingListBody({super.key, required this.state});

  final BookingListState state;

  static String _emptyMessage(BookingTab tab) => switch (tab) {
        BookingTab.allBookings => BookingStrings.emptyAllBookings,
        BookingTab.checkedIn => BookingStrings.emptyCheckedIn,
        BookingTab.upcoming => BookingStrings.emptyUpcoming,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColor.primary,
      onRefresh: () => ref.read(bookingListProvider.notifier).refresh(),
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
                key: ValueKey('empty_${state.tab}_${state.selectedDay.toIso8601String()}'),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 32.h),
                  BookingEmptyState(
                    tab: state.tab,
                    selectedDay: state.selectedDay,
                    message: _emptyMessage(state.tab),
                  ),
                  SizedBox(height: 24.h),
                ],
              )
            : ListView.separated(
                key: ValueKey('list_${state.tab}_${state.selectedDay.toIso8601String()}'),
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
      ),
    );
  }
}
