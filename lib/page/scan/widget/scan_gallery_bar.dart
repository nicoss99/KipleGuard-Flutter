import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_text_style.dart';
import '../scan_strings.dart';

class ScanGalleryBar extends StatelessWidget {
  const ScanGalleryBar({super.key, required this.onPickGallery, this.busy = false});

  final VoidCallback? onPickGallery;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ScanStrings.scanAlignHint,
                  style: AppTextStyle.body.copyWith(color: AppColor.white.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : onPickGallery,
                    icon: Icon(Icons.photo_library_outlined, size: 22.sp, color: AppColor.white),
                    label: Text(ScanStrings.scanFromGallery),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.white,
                      side: BorderSide(color: AppColor.white.withValues(alpha: busy ? 0.25 : 0.85)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
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
