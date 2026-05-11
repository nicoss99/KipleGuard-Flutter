import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../../../theme/app_color.dart';

/// Full-screen preview that fits the image to the screen; tap dimmed area or × to close.
Future<void> showRegisterPhotoPreview(BuildContext context, XFile file) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.88),
    builder: (ctx) {
      final size = MediaQuery.sizeOf(ctx);
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(ctx).pop(),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 56.h),
                  child: Image.file(
                    File(file.path),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(ctx).top + 8.h,
                right: 12.w,
                child: Material(
                  color: AppColor.white.withValues(alpha: 0.2),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: Icon(Icons.close_rounded, color: AppColor.white, size: 26.sp),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
