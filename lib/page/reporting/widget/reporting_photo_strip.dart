import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../../register/widget/register_dashed_border.dart';
import '../../register/widget/register_photo_preview.dart';
import '../reporting_strings.dart';
import 'reporting_section_label.dart';

/// Same layout as register [RegisterPhotoStrip] (empty hero + thumbs + camera/gallery).
class ReportingPhotoStrip extends StatelessWidget {
  const ReportingPhotoStrip({
    super.key,
    required this.photos,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onRemoveAt,
  });

  static const maxPhotos = 5;

  final List<XFile> photos;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final ValueChanged<int> onRemoveAt;

  static double get _thumbSize => 92.w;

  bool get _canAddMore => photos.length < maxPhotos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReportingSectionLabel(text: ReportingStrings.reportAddPhoto),
          Text(
            '${photos.length} / $maxPhotos',
            style: AppTextStyle.bodyMuted,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 8.h),
          if (photos.isEmpty) _emptyHero() else _thumbRow(context),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _canAddMore ? onPickCamera : null,
                  icon: Icon(Icons.photo_camera_rounded, color: AppColor.primary, size: 20.sp),
                  label: Text(ReportingStrings.camera),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primary,
                    side: BorderSide(color: AppColor.primary.withValues(alpha: _canAddMore ? 0.5 : 0.2)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _canAddMore ? onPickGallery : null,
                  icon: Icon(Icons.photo_library_rounded, color: AppColor.primary, size: 20.sp),
                  label: Text(ReportingStrings.gallery),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primary,
                    side: BorderSide(color: AppColor.primary.withValues(alpha: _canAddMore ? 0.5 : 0.2)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyHero() {
    return CustomPaint(
      painter: RegisterDashedBorderPainter(color: AppColor.greyBorder, radius: AppRadius.md),
      child: SizedBox(
        height: 160.h,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_rounded, color: AppColor.primary, size: 40.sp),
              SizedBox(height: 10.h),
              Text(ReportingStrings.photoPickerTitle, style: AppTextStyle.subtitle, textAlign: TextAlign.center),
              SizedBox(height: 6.h),
              Text(ReportingStrings.photoPickerSubtitle, style: AppTextStyle.bodyMuted, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < photos.length; i++) ...[
              _thumb(context, i, photos[i]),
              SizedBox(width: 10.w),
            ],
          ],
        ),
      ),
    );
  }

  Widget _thumb(BuildContext context, int index, XFile file) {
    return Material(
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: _thumbSize,
        height: _thumbSize,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: () => showRegisterPhotoPreview(context, file),
                child: Image.file(File(file.path), fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 6.h,
              right: 6.w,
              child: Material(
                color: AppColor.red,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onRemoveAt(index),
                  child: Padding(
                    padding: EdgeInsets.all(5.w),
                    child: Icon(Icons.close, color: AppColor.white, size: 15.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
