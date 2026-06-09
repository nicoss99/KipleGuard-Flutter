import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import 'register_fade_in.dart';

/// Anchored dropdown panel — optional search field, scrollable options.
class RegisterDropdownOverlay<T> extends StatefulWidget {
  const RegisterDropdownOverlay({
    super.key,
    required this.options,
    required this.value,
    required this.optionLabel,
    required this.onSelect,
    required this.searchHint,
    required this.emptyText,
    this.showSearch = true,
    this.maxListHeight,
  });

  final List<T> options;
  final T? value;
  final String Function(T) optionLabel;
  final ValueChanged<T> onSelect;
  final String searchHint;
  final String emptyText;
  final bool showSearch;
  final double? maxListHeight;

  @override
  State<RegisterDropdownOverlay<T>> createState() => _RegisterDropdownOverlayState<T>();
}

class _RegisterDropdownOverlayState<T> extends State<RegisterDropdownOverlay<T>> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.showSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<T> get _filtered {
    if (!widget.showSearch) return widget.options;
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.options;
    return widget.options.where((o) => widget.optionLabel(o).toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      shadowColor: Colors.black45,
      borderRadius: BorderRadius.circular(12.r),
      color: AppColor.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showSearch) _searchField(),
          _list(),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 6.h),
      child: TextField(
        controller: _search,
        focusNode: _focus,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: widget.searchHint,
          isDense: true,
          filled: true,
          fillColor: AppColor.siteListRowGrey.withValues(alpha: 0.45),
          prefixIcon: Icon(Icons.search_rounded, size: 20.sp, color: AppColor.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10.h),
        ),
      ),
    );
  }

  Widget _list() {
    final filtered = _filtered;
    if (filtered.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(20.w),
        child: Text(widget.emptyText, style: AppTextStyle.bodyMuted, textAlign: TextAlign.center),
      );
    }
    final listMax = widget.maxListHeight ?? (widget.showSearch ? 260.h : 220.h);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: listMax),
      child: Scrollbar(
        thumbVisibility: filtered.length > 6,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: widget.showSearch ? 4.h : 8.h),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            color: AppColor.greyBorder.withValues(alpha: 0.4),
          ),
          itemBuilder: (_, i) => _option(filtered[i], i),
        ),
      ),
    );
  }

  Widget _option(T value, int index) {
    final isSelected = widget.value != null && value == widget.value;
    return RegisterFadeIn(
      index: index,
      child: InkWell(
        onTap: () => widget.onSelect(value),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.optionLabel(value),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body.copyWith(
                    color: isSelected ? AppColor.primary : AppColor.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected) Icon(Icons.check_rounded, color: AppColor.primary, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
