import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../booking_provider.dart';
import '../booking_strings.dart';

/// Active search query chip with clear action.
class BookingSearchChip extends ConsumerWidget {
  const BookingSearchChip({
    super.key,
    required this.query,
    this.onTap,
  });

  final String query;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 6.h),
      child: Material(
        color: AppColor.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 6.h, 4.h, 6.h),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 18.sp, color: AppColor.primary),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '${BookingStrings.searchAction}: $query',
                    style: AppTextStyle.body.copyWith(
                      fontSize: 13.sp,
                      color: AppColor.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      ref.read(bookingListProvider.notifier).clearSearch(),
                  icon: Icon(Icons.close_rounded, size: 20.sp, color: AppColor.primary),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
                  tooltip: BookingStrings.clear,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
