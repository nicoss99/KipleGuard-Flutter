import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_assets.dart';
import '../../../theme/app_color.dart';
import '../dashboard_strings.dart';
import '../dashboard_text_style.dart';
import 'dashboard_bottom_item.dart';
import 'dashboard_svg_icon.dart';

/// Footer row + rounded-square register button (Android `ic_dashboard_*`).
class DashboardBottomBar extends StatelessWidget {
  const DashboardBottomBar({
    super.key,
    required this.intercomEnabled,
    required this.visitorEnabled,
    this.onCall,
    this.onRegister,
    this.onScan,
  });

  final bool intercomEnabled;
  final bool visitorEnabled;
  final VoidCallback? onCall;
  final VoidCallback? onRegister;
  final VoidCallback? onScan;

  static double get _iconSz => 24.sp;

  static ColorFilter get _primaryIconFilter =>
      ColorFilter.mode(AppColor.primary, BlendMode.srcIn);

  @override
  Widget build(BuildContext context) {
    final barHeight = 68.h;
    final fabSize = 48.w;
    final fabLift = 20.h;
    final stackHeight = barHeight + fabLift;
    final callAsset = intercomEnabled ? AppAssets.icDashboardCallBlue : AppAssets.icDashboardCall;
    final callLabelColor = intercomEnabled ? AppColor.primary : AppColor.textPrimary;
    final registerLabelColor = visitorEnabled ? AppColor.primary : AppColor.textPrimary;

    return SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          ColoredBox(
            color: AppColor.lightGreyBar,
            child: SizedBox(
              height: barHeight,
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: DashboardBottomItem(
                      icon: DashboardSvgIcon(
                        asset: callAsset,
                        size: _iconSz,
                        colorFilter: intercomEnabled ? _primaryIconFilter : null,
                      ),
                      label: DashboardStrings.call,
                      labelColor: callLabelColor,
                      onTap: onCall,
                    ),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  Expanded(
                    child: DashboardBottomItem(
                      icon: DashboardSvgIcon(
                        asset: AppAssets.icDashboardQrBlue,
                        size: _iconSz,
                        colorFilter: _primaryIconFilter,
                      ),
                      label: DashboardStrings.scanQr,
                      labelColor: AppColor.primary,
                      onTap: onScan,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  elevation: 4,
                  shadowColor: AppColor.primary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12.r),
                  child: InkWell(
                    onTap: onRegister,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Ink(
                      width: fabSize,
                      height: fabSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColor.primary, AppColor.primaryDark],
                        ),
                      ),
                      child: Center(
                        child: DashboardSvgIcon(
                          asset: AppAssets.icDashboardAddUser,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onRegister,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          DashboardStrings.register,
                          style: DashboardTextStyle.bottomLabel(registerLabelColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
