import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../unit_call_models.dart';
import '../unit_call_strings.dart';
import 'unit_call_selection_tile.dart';

class UnitCallUnitTile extends StatelessWidget {
  const UnitCallUnitTile({
    super.key,
    required this.row,
    required this.expanded,
    required this.index,
    required this.onToggleExpand,
    required this.onMemberTap,
    required this.voipMasking,
    this.hostsLoading = false,
  });

  final CallUnitRow row;
  final bool expanded;
  final int index;
  final VoidCallback onToggleExpand;
  final void Function(UnitMemberLine member) onMemberTap;
  final bool voipMasking;
  final bool hostsLoading;

  String _roleLabel(String type) {
    final t = type.toLowerCase();
    if (t == 'primary' || t == 'owner') return UnitCallStrings.owner;
    if (t == 'admin' || t == 'tenant') return UnitCallStrings.tenant;
    return UnitCallStrings.member;
  }

  @override
  Widget build(BuildContext context) {
    final showsExpandControl = !(row.hostsLoaded && row.members.isEmpty);

    final inner = Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 12.h, AppSpacing.md, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.apartment_rounded, color: AppColor.primary, size: 22.sp),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.name, style: AppTextStyle.subtitle),
                    SizedBox(height: 2.h),
                    Text(row.ownerName, style: AppTextStyle.bodyMuted),
                  ],
                ),
              ),
              if (showsExpandControl)
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: Icon(Icons.expand_more_rounded, color: AppColor.primary, size: 28.sp),
                ),
            ],
          ),
          if (showsExpandControl)
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: _expandedBody(),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );

    return UnitCallFadeInIndex(
      key: ValueKey<String>(row.id),
      index: index,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h, left: AppSpacing.md, right: AppSpacing.md),
        child: Material(
          color: AppColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: AppColor.primary.withValues(alpha: 0.1)),
          ),
          clipBehavior: Clip.antiAlias,
          child: showsExpandControl
              ? InkWell(
                  onTap: onToggleExpand,
                  child: inner,
                )
              : inner,
        ),
      ),
    );
  }

  Widget _expandedBody() {
    if (hostsLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: SizedBox(
            width: 28.w,
            height: 28.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (row.members.isEmpty) {
      return Text(
        row.hostsLoaded ? UnitCallStrings.emptyHosts : UnitCallStrings.loadingHosts,
        style: AppTextStyle.bodyMuted,
      );
    }
    return Column(
      children: row.members.map((m) {
        final tappable = voipMasking || m.phone.trim().length > 5;
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Material(
            color: AppColor.siteListRowGrey.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: InkWell(
              onTap: tappable ? () => onMemberTap(m) : null,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10.h),
                child: Row(
                  children: [
                    Icon(Icons.phone_in_talk_rounded, size: 20.sp, color: AppColor.primary),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: AppTextStyle.body),
                          Text(
                            _roleLabel(m.membershipType),
                            style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
