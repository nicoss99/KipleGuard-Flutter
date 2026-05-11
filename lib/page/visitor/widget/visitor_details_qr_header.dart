import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../theme/app_color.dart';
import '../../home/widget/dashboard_hero_arc_clipper.dart';

/// Full-screen QR preview: square code with quiet zone — avoids clipping/overlap from [AlertDialog].
void showVisitorQrPreviewDialog(BuildContext context, String data) {
  final trimmed = data.trim();
  if (trimmed.isEmpty) return;
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => Dialog(
      backgroundColor: AppColor.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 260.w,
              height: 260.w,
              child: QrImageView(
                data: trimmed,
                version: QrVersions.auto,
                gapless: true,
                backgroundColor: AppColor.white,
                padding: EdgeInsets.all(12.w),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Android `activity_visitordetails.xml`: curved blue header + circular white badge with QR.
class VisitorDetailsQrHeader extends StatelessWidget {
  const VisitorDetailsQrHeader({super.key, required this.qrPayload});

  final String qrPayload;

  @override
  Widget build(BuildContext context) {
    final arcDepth = 20.h;
    final bannerH = 80.h;
    /// Outer diameter of the white circular badge (matches prior layout).
    final badgeDiameter = 110.w;
    /// Square QR must fit inside the circle without clipping modules (inscribed square ≈ d/√2).
    final qrSide = badgeDiameter * 0.68;
    final pad = (badgeDiameter - qrSide) / 2;

    return SizedBox(
      height: 30.h + badgeDiameter + 14.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          ClipPath(
            clipper: DashboardHeroArcClipper(arcDepth: arcDepth),
            child: Container(
              width: double.infinity,
              height: bannerH + arcDepth * 0.5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColor.primaryDark, AppColor.primary],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.h),
            child: Material(
              elevation: 2,
              shadowColor: AppColor.textSecondary.withValues(alpha: 0.35),
              shape: const CircleBorder(),
              color: AppColor.white,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: qrPayload.trim().isEmpty ? null : () => showVisitorQrPreviewDialog(context, qrPayload.trim()),
                child: SizedBox(
                  width: badgeDiameter,
                  height: badgeDiameter,
                  child: Center(
                    child: qrPayload.trim().isEmpty
                        ? Icon(Icons.qr_code_2_rounded, size: 44.sp, color: AppColor.textSecondary)
                        : Padding(
                            padding: EdgeInsets.all(pad),
                            child: SizedBox(
                              width: qrSide,
                              height: qrSide,
                              child: QrImageView(
                                data: qrPayload.trim(),
                                version: QrVersions.auto,
                                gapless: true,
                                backgroundColor: AppColor.white,
                                padding: EdgeInsets.all(4.w),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
