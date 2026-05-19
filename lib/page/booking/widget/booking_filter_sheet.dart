import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../../../widget/app_progress_indicator.dart';
import '../../../theme/app_text_style.dart';
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
  String? _categoryUuid;
  String? _roomUuid;
  bool _pastChip = false;
  List<({String uuid, String name})> _categories = const [];
  List<({String uuid, String name})> _rooms = const [];
  bool _loadingCat = true;
  bool _loadingRooms = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _submittedDay = widget.initial.submittedOnDay;
    _categoryUuid = widget.initial.categoryUuid;
    _roomUuid = widget.initial.roomUuid;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  Future<void> _loadCategories() async {
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final list = await repo.fetchBookingCategories(widget.residenceUuid);
      if (!mounted) return;
      setState(() {
        _categories = list;
        _loadingCat = false;
        _loadError = null;
      });
      final cu = _categoryUuid;
      if (cu != null && cu.isNotEmpty) {
        await _loadRooms(cu);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCat = false;
        _loadError = BookingStrings.loadFailed;
      });
    }
  }

  Future<void> _loadRooms(String typeUuid) async {
    setState(() {
      _loadingRooms = true;
      _rooms = const [];
    });
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final list = await repo.fetchRoomsForBookingType(
        residenceUuid: widget.residenceUuid,
        typeUuid: typeUuid,
      );
      if (!mounted) return;
      setState(() {
        _rooms = list;
        _loadingRooms = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingRooms = false);
    }
  }

  Future<void> _pickSubmitted() async {
    final values = await showCalendarDatePicker2Dialog(
      context: context,
      dialogSize: Size(330.w, 420.h),
      borderRadius: BorderRadius.circular(16.r),
      value: [_submittedDay ?? DateTime.now()],
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDate: DateTime(DateTime.now().year - 2),
        lastDate: DateTime(DateTime.now().year + 2, 12, 31),
        currentDate: DateTime.now(),
        selectedDayHighlightColor: AppColor.primary,
      ),
    );
    if (!mounted) return;
    final picked = (values == null || values.isEmpty) ? null : values.first;
    if (picked != null) {
      setState(() => _submittedDay = DateTime(picked.year, picked.month, picked.day));
    }
  }

  bool get _hasPass =>
      _submittedDay != null ||
      (_categoryUuid != null && _categoryUuid!.isNotEmpty) ||
      (_roomUuid != null && _roomUuid!.isNotEmpty);

  void _onApplyTap() {
    if (_pastChip && !_hasPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(BookingStrings.filterPickOne, style: AppTextStyle.body)),
      );
      return;
    }
    if (!_hasPass) {
      widget.onClear();
      return;
    }
    widget.onApply(
      BookingFilterQuery(
        submittedOnDay: _submittedDay,
        categoryUuid: _categoryUuid,
        roomUuid: _roomUuid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
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
            Text(BookingStrings.category, style: AppTextStyle.subtitle),
            SizedBox(height: 8.h),
            if (_loadingCat)
              const Center(child: AppProgressIndicator())
            else if (_loadError != null)
              Text(_loadError!, style: AppTextStyle.body.copyWith(color: AppColor.red))
            else
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _categories.map((c) {
                  final sel = _categoryUuid == c.uuid;
                  return ChoiceChip(
                    label: Text(c.name, style: AppTextStyle.body),
                    selected: sel,
                    onSelected: (_) async {
                      setState(() {
                        if (sel) {
                          _categoryUuid = null;
                          _roomUuid = null;
                          _rooms = const [];
                        } else {
                          _categoryUuid = c.uuid;
                          _roomUuid = null;
                        }
                      });
                      if (!sel && c.uuid.isNotEmpty) await _loadRooms(c.uuid);
                    },
                    selectedColor: AppColor.primary.withValues(alpha: 0.25),
                  );
                }).toList(),
              ),
            SizedBox(height: 16.h),
            Text(BookingStrings.bookingType, style: AppTextStyle.subtitle),
            SizedBox(height: 8.h),
            if (_loadingRooms)
              const Center(child: AppProgressIndicator())
            else
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _rooms.map((r) {
                  final sel = _roomUuid == r.uuid;
                  return ChoiceChip(
                    label: Text(r.name, style: AppTextStyle.body),
                    selected: sel,
                    onSelected: (_) => setState(() {
                      _roomUuid = sel ? null : r.uuid;
                    }),
                    selectedColor: AppColor.primary.withValues(alpha: 0.25),
                  );
                }).toList(),
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
                    child: Text(BookingStrings.apply, style: AppTextStyle.subtitle.copyWith(color: AppColor.white)),
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
