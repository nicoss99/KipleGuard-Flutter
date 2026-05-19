import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../theme/app_color.dart';
import '../../widget/modal_progress_hud.dart';
import '../../widget/standard_primary_header.dart';
import 'visitor_provider.dart';
import 'visitor_search_delegate.dart';
import 'visitor_state.dart';
import 'visitor_strings.dart';
import 'widget/visitor_calendar_picker.dart';
import 'widget/visitor_date_toolbar.dart';
import 'widget/visitor_error_banner.dart';
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
                if (s.error != null) VisitorErrorBanner(message: s.error!),
                VisitorDateToolbar(
                  state: s,
                  onPickDate: () => _pickDateWithDialog(context, s.selectedDay),
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
    final picked = await showVisitorDayPicker(context: context, selected: selected);
    if (!context.mounted || picked == null) return;
    await ref.read(visitorProvider.notifier).setDay(picked);
  }
}
