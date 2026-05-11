import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../router/app_route.dart' show AppPaths;
import '../../theme/app_color.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import '../../widget/modal_progress_hud.dart';
import 'visitor_provider.dart';
import 'visitor_search_delegate.dart';
import 'visitor_state.dart';
import 'visitor_strings.dart';
import 'widget/visitor_list_tile.dart';

class VisitorPage extends ConsumerStatefulWidget {
  const VisitorPage({super.key});

  @override
  ConsumerState<VisitorPage> createState() => _VisitorPageState();
}

class _VisitorPageState extends ConsumerState<VisitorPage> {
  Future<void> _handleBack(VisitorState s) async {
    if (s.allOvertimeSection) {
      await ref.read(visitorProvider.notifier).setTab(2);
      return;
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(visitorProvider);
    final now = DateTime.now();
    final isToday =
        now.year == s.selectedDay.year && now.month == s.selectedDay.month && now.day == s.selectedDay.day;
    final dayLabel = DateFormat('dd MMM yyyy').format(s.selectedDay);
    final dateHeaderRowHeight = 64.h;

    return PopScope(
      canPop: !s.allOvertimeSection,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack(s);
      },
      child: ModalProgressHud(
        inAsyncCall: s.loading,
        child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: AppBar(
          backgroundColor: AppColor.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => _handleBack(s),
            icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: AppColor.primary),
          ),
          title: Text(
            s.allOvertimeSection ? 'All Overtime' : VisitorStrings.title,
            style: AppTextStyle.title,
          ),
          actions: [
            IconButton(
              onPressed: () async {
                final result = await showSearch<String?>(
                  context: context,
                  delegate: VisitorSearchDelegate(initialQuery: s.searchQuery),
                );
                if (!mounted || result == null) return;
                final q = result.trim();
                if (q.isEmpty) {
                  await ref.read(visitorProvider.notifier).clearSearch();
                } else {
                  await ref.read(visitorProvider.notifier).runSearch(q);
                }
              },
              icon: Icon(Icons.search, size: 24.sp, color: AppColor.textPrimary),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (s.error != null)
              Material(
                color: AppColor.orange.withValues(alpha: 0.12),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8.h),
                  child: Text(s.error!, style: AppTextStyle.body),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.sm, 8.h, AppSpacing.sm, 4.h),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () => ref.read(visitorProvider.notifier).openAllOvertimeSection(),
                    child: Container(
                      width: 104.w,
                      height: dateHeaderRowHeight,
                      decoration: BoxDecoration(
                        color: s.tabIndex == 2 ? AppColor.textPrimary : AppColor.grey.withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: s.tabIndex == 2 ? AppColor.textPrimary : AppColor.orange.withValues(alpha: 0.75),
                          width: 1.4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'All\nOvertime',
                          style: AppTextStyle.body.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: s.tabIndex == 2 ? AppColor.white : AppColor.textPrimary,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      height: dateHeaderRowHeight,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColor.greyBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.textSecondary.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => ref.read(visitorProvider.notifier).previousDay(),
                            icon: Icon(Icons.arrow_circle_left_outlined, size: 24.sp, color: AppColor.primary),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isToday ? 'Today' : dayLabel,
                                  style: AppTextStyle.subtitle.copyWith(fontSize: 17.sp, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                if (isToday)
                                  Text(
                                    dayLabel,
                                    style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp, color: AppColor.primary),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => ref.read(visitorProvider.notifier).nextDay(),
                            icon: Icon(Icons.arrow_circle_right_outlined, size: 24.sp, color: AppColor.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  IconButton(
                    tooltip: 'Pick day',
                    onPressed: () => _pickDateWithDialog(context, s.selectedDay),
                    icon: Icon(LucideIcons.calendar_days, color: AppColor.primary, size: 24.sp),
                  ),
                ],
              ),
            ),
            if (!s.allOvertimeSection) _statusCards(s),
            Expanded(
              child: RefreshIndicator(
                color: AppColor.primary,
                onRefresh: () => ref.read(visitorProvider.notifier).refresh(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is! ScrollEndNotification) return false;
                    final metrics = notification.metrics;
                    if (metrics.axis != Axis.vertical) return false;
                    if (metrics.pixels <= 0) return false;
                    if (metrics.extentAfter == 0) {
                      ref.read(visitorProvider.notifier).loadMore();
                    }
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
                  child: s.items.isEmpty
                      ? ListView(
                          key: ValueKey('empty_${s.tabIndex}_${s.selectedDay.toIso8601String()}_${s.searchQuery}'),
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 80.h),
                            Center(child: Text(VisitorStrings.empty, style: AppTextStyle.bodyMuted)),
                          ],
                        )
                      : ListView.separated(
                          key: ValueKey(
                            'list_${s.tabIndex}_${s.selectedDay.toIso8601String()}_${s.searchQuery}',
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: s.items.length + 1,
                          separatorBuilder: (_, _) => SizedBox(height: 0.h),
                          itemBuilder: (ctx, i) {
                            if (i == s.items.length) {
                              return _paginationFooter(s);
                            }
                            final row = s.items[i];
                            final actionLabel = row.latestScanType.toUpperCase() == 'IN' ? 'Out' : 'In';
                            return VisitorListTile(
                              item: row,
                              onTap: () => context.push(AppPaths.visitorDetails(row.uuid)),
                              onActionTap: () => ref.read(visitorProvider.notifier).quickAction(row),
                              actionLabel: actionLabel,
                            );
                          },
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _statusCards(VisitorState s) {
    Widget card({
      required String label,
      required int? count,
      required int index,
      required Color borderColor,
      required bool selected,
    }) {
      return Expanded(
        child: InkWell(
          onTap: () => ref.read(visitorProvider.notifier).setTab(index),
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            height: 70.h,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: selected ? AppColor.textPrimary : AppColor.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: selected ? AppColor.textPrimary : borderColor,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${count ?? 0}',
                  style: AppTextStyle.subtitle.copyWith(
                    color: selected ? AppColor.white : AppColor.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  style: AppTextStyle.body.copyWith(
                    fontSize: 12.sp,
                    color: selected ? AppColor.white : AppColor.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, 6.h),
      child: Row(
        children: [
          card(
            label: 'Visitor(s)',
            count: s.totalVisitors,
            index: 3,
            borderColor: AppColor.greyBorder,
            selected: s.tabIndex == 3,
          ),
          card(
            label: 'Overtime',
            count: s.totalOvertime,
            index: 2,
            borderColor: AppColor.red,
            selected: s.tabIndex == 2,
          ),
          card(
            label: 'Checked In',
            count: s.totalCheckIn,
            index: 0,
            borderColor: AppColor.green,
            selected: s.tabIndex == 0,
          ),
          card(
            label: 'Upcoming',
            count: s.totalIncoming,
            index: 1,
            borderColor: AppColor.orange,
            selected: s.tabIndex == 1,
          ),
        ],
      ),
    );
  }

  Widget _paginationFooter(VisitorState s) {
    final footerKey = s.loadingMore
        ? 'loading'
        : (!s.hasMore ? 'end' : 'idle');
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: switch (footerKey) {
        'loading' => Container(
          key: const ValueKey('pagination_loading'),
          margin: EdgeInsets.fromLTRB(AppSpacing.sm, 6.h, AppSpacing.sm, 10.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColor.greyBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10.w),
              Text(
                'Loading more visitor...',
                style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
              ),
            ],
          ),
        ),
        'end' => Padding(
          key: const ValueKey('pagination_end'),
          padding: EdgeInsets.fromLTRB(AppSpacing.sm, 4.h, AppSpacing.sm, 10.h),
          child: Center(
            child: Text(
              'No more visitor',
              style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
            ),
          ),
        ),
        _ => SizedBox(key: const ValueKey('pagination_idle'), height: 8.h),
      },
    );
  }

  Future<void> _pickDateWithDialog(BuildContext context, DateTime selected) async {
    final values = await showCalendarDatePicker2Dialog(
      context: context,
      dialogSize: Size(330.w, 420.h),
      borderRadius: BorderRadius.circular(16.r),
      value: [selected],
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDate: DateTime(selected.year - 1, 1, 1),
        lastDate: DateTime(selected.year + 2, 12, 31),
        currentDate: DateTime.now(),
        selectedDayHighlightColor: AppColor.primary,
        selectedDayTextStyle: AppTextStyle.body.copyWith(
          color: AppColor.white,
          fontWeight: FontWeight.w600,
        ),
        controlsTextStyle: AppTextStyle.subtitle.copyWith(fontSize: 16.sp),
        dayTextStyle: AppTextStyle.body,
        weekdayLabelTextStyle: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
        okButton: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Text('OK', style: AppTextStyle.subtitle.copyWith(color: AppColor.primary)),
        ),
        cancelButton: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Text('Cancel', style: AppTextStyle.bodyMuted),
        ),
      ),
    );
    if (!context.mounted) return;
    final picked = (values == null || values.isEmpty) ? null : values.first;
    if (picked != null) {
      await ref.read(visitorProvider.notifier).setDay(DateTime(picked.year, picked.month, picked.day));
    }
  }
}
