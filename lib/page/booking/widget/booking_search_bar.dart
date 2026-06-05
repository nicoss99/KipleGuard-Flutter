import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../booking_list_filters.dart';
import '../booking_provider.dart';
import '../booking_strings.dart';

/// Inline booking search with debounced API + local filtering.
class BookingSearchBar extends ConsumerStatefulWidget {
  const BookingSearchBar({
    super.key,
    required this.initialQuery,
    required this.onClose,
  });

  final String initialQuery;
  final VoidCallback onClose;

  @override
  ConsumerState<BookingSearchBar> createState() => _BookingSearchBarState();
}

class _BookingSearchBarState extends ConsumerState<BookingSearchBar> {
  late final TextEditingController _controller;
  final _focus = FocusNode();
  Timer? _debounce;
  var _draftLen = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _draftLen = widget.initialQuery.trim().length;
    _controller.addListener(_onDraftChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onDraftChanged);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onDraftChanged() => setState(() => _draftLen = _controller.text.trim().length);

  void _submit(String raw) {
    final t = raw.trim();
    if (t.isEmpty) {
      ref.read(bookingListProvider.notifier).clearSearch();
      return;
    }
    if (t.length < 3) return;
    ref.read(bookingListProvider.notifier).setSearchQuery(t);
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final t = value.trim();
    if (t.isEmpty) {
      ref.read(bookingListProvider.notifier).clearSearch();
      return;
    }
    if (t.length < 3) return;
    _debounce = Timer(const Duration(milliseconds: 400), () => _submit(t));
  }

  @override
  Widget build(BuildContext context) {
    final showMinHint = _draftLen > 0 && _draftLen < 3;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 4.h, AppSpacing.md, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: AppColor.white,
            elevation: 1,
            shadowColor: AppColor.textPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              style: AppTextStyle.body,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: BookingStrings.searchHint,
                hintStyle: AppTextStyle.bodyMuted,
                prefixIcon: Icon(Icons.search_rounded, color: AppColor.primary, size: 22.sp),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _controller.clear();
                          ref.read(bookingListProvider.notifier).clearSearch();
                        },
                        icon: Icon(Icons.clear_rounded, size: 20.sp, color: AppColor.textMuted),
                      ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: Icon(Icons.keyboard_arrow_up_rounded, size: 24.sp, color: AppColor.primary),
                      tooltip: BookingStrings.cancel,
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(64)],
              onChanged: _onChanged,
              onSubmitted: _submit,
            ),
          ),
          if (showMinHint)
            Padding(
              padding: EdgeInsets.only(top: 6.h, left: 4.w),
              child: Text(
                BookingStrings.searchMinChars,
                style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp, color: AppColor.orange),
              ),
            )
          else if (bookingSearchActive(_controller.text))
            Padding(
              padding: EdgeInsets.only(top: 6.h, left: 4.w),
              child: Text(
                BookingStrings.searchScopeHint,
                style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
              ),
            ),
        ],
      ),
    );
  }
}
