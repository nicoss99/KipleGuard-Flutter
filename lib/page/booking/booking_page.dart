import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/dashboard_prefs.dart';
import '../../theme/app_color.dart';
import '../../theme/app_radius.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/app_calendar_picker.dart';
import '../../widget/modal_progress_hud.dart';
import '../../core/connectivity/connectivity_refresh.dart';
import '../../widget/offline_cache_banner.dart';
import '../../widget/standard_primary_header.dart';
import 'booking_provider.dart';
import 'booking_strings.dart';
import 'widget/booking_date_toolbar.dart';
import 'widget/booking_filter_sheet.dart';
import 'widget/booking_list_body.dart';
import 'widget/booking_summary_row.dart';

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({super.key});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(bookingListProvider);
    listenConnectivityRefresh(ref, () {
      ref.read(bookingListProvider.notifier).refresh();
    });
    ref.listen(bookingListProvider, (prev, next) {
      final err = next.error;
      if (err == null || err == prev?.error || !mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showApiFailedDialog(context, message: err);
        ref.read(bookingListProvider.notifier).clearError();
      });
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: ModalProgressHud(
        inAsyncCall: s.loading,
        child: Scaffold(
          backgroundColor: AppColor.lightGreyBar,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StandardPrimaryHeader(
                title: BookingStrings.title,
                onBack: () => context.pop(),
                actions: [
                  IconButton(
                    onPressed: () => _openSearch(s.searchQuery),
                    icon: Icon(Icons.search_rounded, size: 24.sp, color: AppColor.primary),
                  ),
                  IconButton(
                    onPressed: _openFilter,
                    icon: Icon(Icons.filter_list_rounded, size: 24.sp, color: AppColor.primary),
                  ),
                ],
              ),
              BookingDateToolbar(
                state: s,
                onPickDate: () => _pickDateWithDialog(s.selectedDay),
              ),
              OfflineCacheBanner(
                fromCache: s.fromCache,
                savedAt: s.cacheSavedAt,
              ),
              BookingSummaryRow(state: s),
              Expanded(child: BookingListBody(state: s)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateWithDialog(DateTime selected) async {
    final picked = await AppCalendarPicker.showDay(
      context: context,
      initial: selected,
      okLabel: BookingStrings.apply,
    );
    if (!mounted || picked == null) return;
    await ref.read(bookingListProvider.notifier).setDay(picked);
  }

  Future<void> _openFilter() async {
    final snap = await DashboardPrefs.loadSnapshot();
    if (!mounted || snap.residenceId.isEmpty) return;
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

  Future<void> _openSearch(String initialQuery) async {
    final controller = TextEditingController(text: initialQuery);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(BookingStrings.searchTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: BookingStrings.searchHint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(BookingStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(BookingStrings.searchAction),
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
        await showApiFailedDialog(context, message: BookingStrings.searchMinChars);
      }
    }
    controller.dispose();
  }
}
