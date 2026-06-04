import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_assets.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../attendance_model.dart';
import '../attendance_strings.dart';

/// Android `adapter_attendance.xml`.
class AttendanceRecordTile extends StatelessWidget {
  const AttendanceRecordTile({super.key, required this.row});

  final AttendanceRecordRow row;

  @override
  Widget build(BuildContext context) {
    final photo = 100.w;
    final hasOut = row.checkOutDisplay != null;
    final checkIn = row.checkInDisplay;
    final checkOut = row.checkOutDisplay;
    final code = row.guardCode.trim();

    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 0),
      child: Material(
        color: AppColor.white,
        elevation: 2,
        shadowColor: AppColor.textPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: row.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: row.imageUrl,
                            width: photo,
                            height: photo,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => _photoPlaceholder(photo),
                          )
                        : _photoPlaceholder(photo),
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5.w, 0.h, 4.w, 0.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (code.isNotEmpty)
                        Text(
                          code,
                          style: AppTextStyle.body.copyWith(
                            fontSize: 14.sp,
                            color: AppColor.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        row.guardName,
                        style: AppTextStyle.body.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColor.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (checkIn.trim().isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        _TimeRow(
                          asset: AppAssets.icVisitorCheckin,
                          label: AttendanceStrings.recordCheckIn,
                          value: checkIn,
                        ),
                      ],
                      if (hasOut) ...[
                        SizedBox(height: 6.h),
                        _TimeRow(
                          asset: AppAssets.icVisitorCheckout,
                          label: AttendanceStrings.recordCheckOut,
                          value: checkOut!,
                        ),
                      ],
                    ],
                  ),
                ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(5.w),
                    child: _StatusIcon(checkedInOnly: row.isCheckedInOnly),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: AppColor.grey,
      child: Icon(Icons.person, color: AppColor.textSecondary, size: 40.sp),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.checkedInOnly});

  final bool checkedInOnly;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: SvgPicture.asset(
          checkedInOnly ? AppAssets.icVisitorCheckin : AppAssets.icVisitorCheckout,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.asset,
    required this.label,
    required this.value,
  });

  final String asset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    final iconSize = 14.w;
    final gap = 5.w;
    final labelStyle = AppTextStyle.bodyMuted.copyWith(
      fontSize: 11.sp,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              asset,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
            SizedBox(width: gap),
            Text(label, style: labelStyle),
          ],
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.only(left: iconSize + gap),
          child: Text(
            value,
            style: AppTextStyle.body.copyWith(
              fontSize: 12.sp,
              height: 1.3,
              color: AppColor.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
