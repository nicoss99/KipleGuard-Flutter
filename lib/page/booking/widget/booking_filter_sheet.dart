import '../../../widget/app_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../../../widget/api_failed_dialog.dart';
import '../booking_filter_models.dart';
import '../booking_filter_query.dart';
import '../booking_repository.dart';
import '../booking_strings.dart';

class BookingFilterSheet extends ConsumerStatefulWidget {
  const BookingFilterSheet({
    super.key,
    required this.residenceUuid,
    required this.initial,
    required this.onApply,
    required this.onClear,
  });

  final String residenceUuid;
  final BookingFilterQuery initial;
  final void Function(BookingFilterQuery query) onApply;
  final VoidCallback onClear;

  @override
  ConsumerState<BookingFilterSheet> createState() => _BookingFilterSheetState();
}

class _BookingFilterSheetState extends ConsumerState<BookingFilterSheet> {
  DateTime? _submittedDay;
  bool _pastChip = false;
  int? _facilityId;
  String? _facilityLabel;
  GuardBookingFilters? _filters;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _submittedDay = widget.initial.submittedOnDay;
    _facilityId = widget.initial.facilityId;
    _facilityLabel = widget.initial.facilityLabel;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFilters());
  }

  Future<void> _loadFilters() async {
    try {
      final filters = await ref
          .read(bookingRepositoryProvider)
          .fetchBookingFilters(residenceUuid: widget.residenceUuid);
      if (!mounted) return;
      setState(() {
        _filters = filters;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = BookingStrings.loadFailed;
      });
    }
  }

  Future<void> _pickSubmitted() async {
    final picked = await AppCalendarPicker.showDay(
      context: context,
      initial: _submittedDay ?? DateTime.now(),
    );
    if (!mounted) return;
    if (picked != null) setState(() => _submittedDay = picked);
  }

  bool get _hasPass => _submittedDay != null || _facilityId != null;

  Future<void> _onApplyTap() async {
    if (_pastChip && !_hasPass) {
      await showApiFailedDialog(context, message: BookingStrings.filterPickOne);
      return;
    }
    if (!_hasPass) {
      widget.onClear();
      return;
    }
    widget.onApply(
      BookingFilterQuery(
        submittedOnDay: _submittedDay,
        facilityId: _facilityId,
        facilityLabel: _facilityLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final facilities = _filters?.facilities ?? const <BookingFacilityFilter>[];

    return Padding(
      padding: EdgeInsets.only(bottom: bottom + 12.h),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppSpacing.md, 12.h, AppSpacing.md, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(BookingStrings.bookingStatus, style: AppTextStyle.subtitle),
            Text(BookingStrings.lastUpdatedToday, style: AppTextStyle.bodyMuted),
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: Text(BookingStrings.pastBookingChip, style: AppTextStyle.body),
                selected: _pastChip,
                onSelected: (v) => setState(() => _pastChip = v),
                selectedColor: AppColor.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColor.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: Text(BookingStrings.submittedOn, style: AppTextStyle.subtitle)),
                TextButton.icon(
                  onPressed: _pickSubmitted,
                  icon: Icon(Icons.calendar_today_rounded, size: 18.sp, color: AppColor.primary),
                  label: Text(
                    _submittedDay == null
                        ? BookingStrings.chooseDate
                        : MaterialLocalizations.of(context).formatCompactDate(_submittedDay!),
                    style: AppTextStyle.body.copyWith(color: AppColor.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(BookingStrings.bookingType, style: AppTextStyle.subtitle),
            SizedBox(height: 8.h),
            if (_loading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (_loadError != null)
              Text(_loadError!, style: AppTextStyle.body.copyWith(color: AppColor.red))
            else if (facilities.isEmpty)
              Text(BookingStrings.noBookingListed, style: AppTextStyle.bodyMuted)
            else
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (final f in facilities)
                    FilterChip(
                      label: Text(f.label, style: AppTextStyle.body),
                      selected: _facilityId == f.id,
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _facilityId = f.id;
                          _facilityLabel = f.label;
                        } else {
                          _facilityId = null;
                          _facilityLabel = null;
                        }
                      }),
                      selectedColor: AppColor.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColor.primary,
                    ),
                ],
              ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClear,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.primary,
                      side: const BorderSide(color: AppColor.primary),
                    ),
                    child: Text(BookingStrings.clear, style: AppTextStyle.subtitle),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: _onApplyTap,
                    style: FilledButton.styleFrom(backgroundColor: AppColor.primary),
                    child: Text(
                      BookingStrings.apply,
                      style: AppTextStyle.subtitle.copyWith(color: AppColor.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
