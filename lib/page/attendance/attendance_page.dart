import 'dart:async';


import '../../widget/app_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../theme/app_color.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/modal_progress_hud.dart';
import '../../widget/standard_primary_header.dart';
import 'attendance_model.dart';
import 'attendance_provider.dart';
import 'attendance_state.dart';
import 'attendance_strings.dart';
import 'widget/attendance_day_strip.dart';
import 'widget/attendance_shift_dialog.dart';
import 'widget/attendance_record_tile.dart';
import 'widget/attendance_records_date_header.dart';
import 'widget/attendance_records_empty_state.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(_onTab);
  }

  void _onTab() {
    if (!_tabs.indexIsChanging) {
      ref.read(attendanceProvider.notifier).setTab(_tabs.index);
    }
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTab);
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(attendanceProvider);
    ref.listen(attendanceProvider, (prev, next) {
      final err = next.error;
      if (err == null || err == prev?.error || !mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showApiFailedDialog(context, message: err);
        ref.read(attendanceProvider.notifier).clearError();
      });
    });
    final title = s.tabIndex == 0
        ? AttendanceStrings.titleTaking
        : AttendanceStrings.titleRecords;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: ModalProgressHud(
        inAsyncCall: s.loading,
        child: Scaffold(
          backgroundColor: AppColor.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StandardPrimaryHeader(title: title, onBack: () => context.pop()),
              Material(
                color: AppColor.white,
                child: TabBar(
                  controller: _tabs,
                  labelColor: AppColor.textPrimary,
                  unselectedLabelColor: AppColor.textSecondary,
                  labelStyle: AppTextStyle.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                  unselectedLabelStyle: AppTextStyle.body.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 15.sp,
                    color: AppColor.textSecondary,
                  ),
                  indicatorColor: AppColor.primary,
                  indicatorWeight: 5,
                  tabs: [
                    Tab(text: AttendanceStrings.tabTaking),
                    Tab(text: AttendanceStrings.tabRecords),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _TakingTab(
                      onStart: () => _shiftFlow(AttendanceShiftFlow.startShift),
                      onEnd: () => _shiftFlow(AttendanceShiftFlow.endShift),
                    ),
                    _RecordsTab(
                      selectedDay: s.selectedDay,
                      records: s.records,
                      error: s.error,
                      onRefresh: () => ref
                          .read(attendanceProvider.notifier)
                          .refreshRecords(),
                      onPickDate: () => _pickDate(s.selectedDay),
                      onShiftMonth: (delta) => ref
                          .read(attendanceProvider.notifier)
                          .setSelectedDay(_shiftMonth(s.selectedDay, delta)),
                      onSelectDay: (d) => ref
                          .read(attendanceProvider.notifier)
                          .setSelectedDay(d),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _shiftMonth(DateTime d, int delta) {
    final shifted = DateTime(d.year, d.month + delta, 1);
    final last = DateTime(shifted.year, shifted.month + 1, 0).day;
    final day = d.day.clamp(1, last);
    return DateTime(shifted.year, shifted.month, day);
  }

  Future<void> _pickDate(DateTime current) async {
    final picked = await AppCalendarPicker.showDay(context: context, initial: current);
    if (!mounted) return;
    if (picked != null) {
      await ref
          .read(attendanceProvider.notifier)
          .setSelectedDay(DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _shiftFlow(AttendanceShiftFlow flow) async {
    final pageCtx = context;
    await AttendanceShiftDialog.show(
      context: context,
      pageContext: pageCtx,
      ref: ref,
      flow: flow,
    );
  }
}

class _TakingTab extends StatefulWidget {
  const _TakingTab({required this.onStart, required this.onEnd});

  final VoidCallback onStart;
  final VoidCallback onEnd;

  @override
  State<_TakingTab> createState() => _TakingTabState();
}

class _TakingTabState extends State<_TakingTab> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeFmt = DateFormat('hh:mm', 'en_US');
    final ampm = DateFormat('a', 'en_US').format(now);
    final dateLine = DateFormat('EEEE, dd MMM yyyy', 'en_US').format(now);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 32.h),
      child: Column(
        children: [
          SizedBox(height: 28.h),
          Text(
            dateLine,
            style: AppTextStyle.body.copyWith(
              fontSize: 14.sp,
              color: AppColor.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                timeFmt.format(now),
                style: AppTextStyle.body.copyWith(
                  fontSize: 42.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                ampm,
                style: AppTextStyle.subtitle.copyWith(
                  fontSize: 18.sp,
                  color: AppColor.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 36.h),
          _BilingualShiftButton(
            background: AppColor.primary,
            title: AttendanceStrings.startShiftTitle,
            subtitle: AttendanceStrings.startShiftSubtitle,
            onTap: widget.onStart,
          ),
          SizedBox(height: 14.h),
          _BilingualShiftButton(
            background: AppColor.red,
            title: AttendanceStrings.endShiftTitle,
            subtitle: AttendanceStrings.endShiftSubtitle,
            onTap: widget.onEnd,
          ),
        ],
      ),
    );
  }
}

class _BilingualShiftButton extends StatelessWidget {
  const _BilingualShiftButton({
    required this.background,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color background;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12.r),
        elevation: 2,
        shadowColor: AppColor.textPrimary.withValues(alpha: 0.12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 26.h, horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.subtitle.copyWith(
                    color: AppColor.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.body.copyWith(
                    color: AppColor.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordsTab extends StatelessWidget {
  const _RecordsTab({
    required this.selectedDay,
    required this.records,
    required this.error,
    required this.onRefresh,
    required this.onPickDate,
    required this.onShiftMonth,
    required this.onSelectDay,
  });

  final DateTime selectedDay;
  final List<AttendanceRecordRow> records;
  final String? error;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onPickDate;
  final ValueChanged<int> onShiftMonth;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColor.lightGreyBar,
      child: RefreshIndicator(
        color: AppColor.primary,
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AttendanceRecordsDateHeader(
                selectedDay: selectedDay,
                onPickDate: () => onPickDate(),
                onShiftMonth: onShiftMonth,
              ),
            ),
            SliverToBoxAdapter(
              child: AttendanceDayStrip(
                monthDate: selectedDay,
                selectedDay: selectedDay,
                onSelectDay: onSelectDay,
              ),
            ),
            if (error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.md, 8.h, AppSpacing.md, 0),
                  child: Material(
                    color: AppColor.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Text(error!, style: AppTextStyle.body.copyWith(color: AppColor.red)),
                    ),
                  ),
                ),
              ),
            if (records.isEmpty)
              const SliverToBoxAdapter(child: AttendanceRecordsEmptyState())
            else
              SliverPadding(
                padding: EdgeInsets.only(top: 4.h, bottom: 80.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => AttendanceRecordTile(row: records[i]),
                    childCount: records.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
