import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import 'register_dropdown_overlay.dart';

/// Card-style trigger that opens an anchored dropdown below.
class RegisterDropdownCard<T> extends StatefulWidget {
  const RegisterDropdownCard({
    super.key,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
    required this.hint,
    required this.enabled,
    this.showSearch = true,
    this.searchHint = 'Search',
    this.emptyText = 'No matches',
  });

  final T? value;
  final List<T> options;
  final String Function(T) optionLabel;
  final ValueChanged<T?> onChanged;
  final String hint;
  final bool enabled;
  final bool showSearch;
  final String searchHint;
  final String emptyText;

  @override
  State<RegisterDropdownCard<T>> createState() => _RegisterDropdownCardState<T>();
}

class _RegisterDropdownCardState<T> extends State<RegisterDropdownCard<T>> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  double _triggerWidth = 0;
  bool _open = false;

  void _toggle() {
    if (_open) {
      _close();
    } else {
      _show();
    }
  }

  void _show() {
    _portal.show();
    setState(() => _open = true);
  }

  void _close() {
    if (_portal.isShowing) _portal.hide();
    if (mounted) setState(() => _open = false);
  }

  void _select(T value) {
    widget.onChanged(value);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (_) => _overlayTree(),
        child: LayoutBuilder(
          builder: (context, c) {
            _triggerWidth = c.maxWidth;
            return _triggerCard();
          },
        ),
      ),
    );
  }

  Widget _triggerCard() {
    final hasValue = widget.value != null;
    final canOpen = widget.enabled && widget.options.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: _open ? AppColor.primary.withValues(alpha: 0.45) : Colors.transparent,
          width: _open ? 1.5 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _open ? 0.12 : 0.08),
            blurRadius: _open ? 10 : 6,
            offset: Offset(0, _open ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: canOpen ? _toggle : null,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? widget.optionLabel(widget.value as T) : widget.hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.body.copyWith(
                      color: hasValue ? AppColor.textPrimary : AppColor.textSecondary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: Icon(Icons.keyboard_arrow_down, color: AppColor.textSecondary, size: 22.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _overlayTree() {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: Offset(0, 8.h),
          child: SizedBox(
            width: _triggerWidth,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              builder: (_, t, child) {
                final e = Curves.easeOutCubic.transform(t);
                return Opacity(
                  opacity: e,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - e)),
                    child: Transform.scale(
                      scale: 0.92 + 0.08 * e,
                      alignment: Alignment.topCenter,
                      child: child,
                    ),
                  ),
                );
              },
              child: RegisterDropdownOverlay<T>(
                options: widget.options,
                value: widget.value,
                optionLabel: widget.optionLabel,
                onSelect: _select,
                searchHint: widget.searchHint,
                emptyText: widget.emptyText,
                showSearch: widget.showSearch,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
