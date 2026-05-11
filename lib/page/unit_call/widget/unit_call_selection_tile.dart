import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';

class UnitCallSelectionTile extends StatelessWidget {
  const UnitCallSelectionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.index = 0,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    return UnitCallFadeInIndex(
      index: index,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h, left: AppSpacing.md, right: AppSpacing.md),
        child: Material(
          color: AppColor.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: AppColor.primary.withValues(alpha: 0.12)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(icon, color: AppColor.primary, size: 22.sp),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(title, style: AppTextStyle.subtitle)),
                  Icon(Icons.chevron_right_rounded, color: AppColor.primary, size: 26.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Real staggered entrance for list rows — each row starts after the previous one.
class UnitCallFadeInIndex extends StatefulWidget {
  const UnitCallFadeInIndex({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<UnitCallFadeInIndex> createState() => _UnitCallFadeInIndexState();
}

class _UnitCallFadeInIndexState extends State<UnitCallFadeInIndex>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  late final Animation<double> _anim = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    final delayMs = (widget.index * 45).clamp(0, 360);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = _anim.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - t)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
