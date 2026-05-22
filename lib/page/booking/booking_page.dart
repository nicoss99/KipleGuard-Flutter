import '../../widget/app_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/dashboard_prefs.dart';
import '../../router/app_route.dart';
import '../../theme/app_color.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import '../../widget/modal_progress_hud.dart';
import '../../widget/app_progress_indicator.dart';
import '../../widget/standard_primary_header.dart';
import 'booking_provider.dart';
import 'booking_strings.dart';
import 'widget/booking_filter_sheet.dart';
import 'widget/booking_list_tile.dart';

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({super.key});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  bool _isCalendarToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingListProvider.notifier).refresh();
    });
  }

  Future<void> _pickDate(DateTime current) async {
    final picked = await AppCalendarPicker.showDay(context: context, initial: current);
    if (!mounted) return;
    if (picked != null) {
      await ref.read(bookingListProvider.notifier).setDay(picked);
    }
  }

  Future<void> _openFilter() async {
    final snap = await DashboardPrefs.loadSnapshot();
    if (!mounted) return;
    if (snap.residenceId.isEmpty) return;
    final s = ref.read(bookingListProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: BookingFilterSheet(
          residenceUuid: snap.residenceId,
          initial: s.filterQuery,
          onApply: (q) {
            Navigator.pop(ctx);
            ref.read(bookingListProvider.notifier).applyFilters(q);
          },
          onClear: () {
            Navigator.pop(ctx);
            ref.read(bookingListProvider.notifier).clearListFilters();
          },
        ),
      ),
    );
  }

  Future<void> _openSearch() async {
    final s = ref.read(bookingListProvider);
    final controller = TextEditingController(text: s.searchQuery);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(BookingStrings.searchTitle, style: AppTextStyle.subtitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: BookingStrings.searchHint),
          style: AppTextStyle.body,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(BookingStrings.cancel, style: AppTextStyle.bodyMuted),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              BookingStrings.searchAction,
              style: AppTextStyle.subtitle.copyWith(color: AppColor.white),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true) {
      final t = controller.text.trim();
      if (t.isEmpty) {
        await ref.read(bookingListProvider.notifier).setSearchQuery('');
      } else if (t.length >= 3) {
        await ref.read(bookingListProvider.notifier).setSearchQuery(t);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(BookingStrings.searchMinChars, style: AppTextStyle.body)),
        );
      }
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(bookingListProvider);
    final n = ref.read(bookingListProvider.notifier);
    final isToday = _isCalendarToday(s.selectedDay);
    final dayLabel = isToday
        ? BookingStrings.today
        : DateFormat('d MMM yyyy', 'en_US').format(s.selectedDay);
    final appBarTitle = isToday ? BookingStrings.title : BookingStrings.pastBookingTitle;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: ModalProgressHud(
        inAsyncCall: s.loading,
        child: Scaffold(
          backgroundColor: AppColor.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StandardPrimaryHeader(
                title: appBarTitle,
                onBack: () => context.pop(),
                actions: isToday
                    ? <Widget>[
                        IconButton(
                          onPressed: _openSearch,
                          icon: Icon(Icons.search_rounded, color: AppColor.black, size: 24.sp),
                        ),
                        IconButton(
                          onPressed: _openFilter,
                          icon: Icon(Icons.filter_list_rounded, color: AppColor.black, size: 24.sp),
                        ),
                      ]
                    : const [],
              ),
              Material(
                color: AppColor.white,
                child: SizedBox(
                  height: 52.h,
                  child: isToday
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => n.setDay(
                                s.selectedDay.subtract(const Duration(days: 1)),
                              ),
                              icon: Icon(
                                Icons.chevron_left_rounded,
                                color: AppColor.primary,
                                size: 28.sp,
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => _pickDate(s.selectedDay),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                    child: Text(
                                      dayLabel,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyle.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  n.setDay(s.selectedDay.add(const Duration(days: 1))),
                              icon: Icon(
                                Icons.chevron_right_rounded,
                                color: AppColor.primary,
                                size: 28.sp,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _pickDate(s.selectedDay),
                              icon: Icon(
                                Icons.calendar_today_rounded,
                                color: AppColor.primary,
                                size: 18.sp,
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () => n.setDay(
                                    s.selectedDay.subtract(const Duration(days: 1)),
                                  ),
                                  icon: Icon(
                                    Icons.chevron_left_rounded,
                                    color: AppColor.primary,
                                    size: 28.sp,
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _pickDate(s.selectedDay),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                        child: Text(
                                          dayLabel,
                                          textAlign: TextAlign.center,
                                          style: AppTextStyle.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 48.w),
                              ],
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        n.setDay(s.selectedDay.add(const Duration(days: 1))),
                                    icon: Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColor.primary,
                                      size: 28.sp,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _pickDate(s.selectedDay),
                                    icon: Icon(
                                      Icons.calendar_today_rounded,
                                      color: AppColor.primary,
                                      size: 18.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (s.error != null)
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    s.error!,
                    style: AppTextStyle.body.copyWith(color: AppColor.red),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColor.primary,
                  onRefresh: () => n.refresh(),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (note) {
                      if (note.metrics.pixels >=
                          note.metrics.maxScrollExtent - 120) {
                        n.loadMore();
                      }
                      return false;
                    },
                    child: s.items.isEmpty && !s.loading
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 80.h),
                              Center(
                                child: Text(
                                  BookingStrings.noBookingListed,
                                  style: AppTextStyle.bodyMuted,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 24.h),
                            itemCount: s.items.length + (s.loadingMore ? 1 : 0),
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              color: AppColor.greyBorder.withValues(
                                alpha: 0.35,
                              ),
                            ),
                            itemBuilder: (ctx, i) {
                              if (i >= s.items.length) {
                                return Padding(
                                  padding: EdgeInsets.all(16.h),
                                  child: const Center(
                                    child: AppProgressIndicator.compact(),
                                  ),
                                );
                              }
                              final item = s.items[i];
                              return BookingListTile(
                                item: item,
                                onTap: () => context.pushNamed(
                                  AppRoute.bookingDetail.name,
                                  pathParameters: {'bookingUuid': item.uuid},
                                ),
                              );
                            },
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
}
