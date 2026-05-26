import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../theme/app_color.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/modal_progress_hud.dart';
import '../../core/connectivity/connectivity_refresh.dart';
import '../../widget/offline_cache_banner.dart';
import '../../widget/standard_primary_header.dart';
import 'visitor_provider.dart';
import 'visitor_search_delegate.dart';
import 'visitor_state.dart';
import 'visitor_strings.dart';
import '../../widget/app_calendar_picker.dart';
import 'widget/visitor_date_toolbar.dart';
import 'widget/visitor_list_body.dart';
import 'widget/visitor_summary_row.dart';

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
    listenConnectivityRefresh(ref, () {
      ref.read(visitorProvider.notifier).refresh();
    });
    ref.listen(visitorProvider, (prev, next) {
      final err = next.error;
      if (err == null || err == prev?.error || !mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showApiFailedDialog(context, message: err);
        ref.read(visitorProvider.notifier).clearError();
      });
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: PopScope(
        canPop: !s.allOvertimeSection,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _handleBack(s);
        },
        child: ModalProgressHud(
          inAsyncCall: s.loading,
          child: Scaffold(
            backgroundColor: AppColor.lightGreyBar,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StandardPrimaryHeader(
                  title: s.allOvertimeSection ? 'All Overtime' : VisitorStrings.title,
                  onBack: () => _handleBack(s),
                  actions: [
                    IconButton(
                      onPressed: () => _openSearch(context, s.searchQuery),
                      icon: Icon(Icons.search_rounded, size: 24.sp, color: AppColor.primary),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                if (!s.allOvertimeSection)
                  VisitorDateToolbar(
                    state: s,
                    onPickDate: () => _pickDateWithDialog(context, s.selectedDay),
                  ),
                OfflineCacheBanner(
                  fromCache: s.fromCache,
                  savedAt: s.cacheSavedAt,
                ),
                if (!s.allOvertimeSection) VisitorSummaryRow(state: s),
                Expanded(child: VisitorListBody(state: s)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSearch(BuildContext context, String initialQuery) async {
    final result = await showSearch<String?>(
      context: context,
      delegate: VisitorSearchDelegate(initialQuery: initialQuery),
    );
    if (!mounted || result == null) return;
    final q = result.trim();
    if (q.isEmpty) {
      await ref.read(visitorProvider.notifier).clearSearch();
    } else {
      await ref.read(visitorProvider.notifier).runSearch(q);
    }
  }

  Future<void> _pickDateWithDialog(BuildContext context, DateTime selected) async {
    final picked = await AppCalendarPicker.showDay(
      context: context,
      initial: selected,
      okLabel: 'Apply',
    );
    if (!context.mounted || picked == null) return;
    await ref.read(visitorProvider.notifier).setDay(picked);
  }
}
