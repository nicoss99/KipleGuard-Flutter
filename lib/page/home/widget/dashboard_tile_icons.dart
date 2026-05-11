import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_assets.dart';
import 'dashboard_svg_icon.dart';

/// Android `ic_dashboard_*` artwork (ported as SVG under [AppAssets]).
class DashboardTileIcons {
  static double get _sz => 40.sp;

  static Widget attendance({required bool enabled}) => DashboardSvgIcon(
        asset: enabled ? AppAssets.icDashboardSchedule : AppAssets.icDashboardScheduleGrey,
        size: _sz,
      );

  static Widget visitor({required bool enabled}) => DashboardSvgIcon(
        asset: enabled ? AppAssets.icDashboardUser : AppAssets.icDashboardUserGrey,
        size: _sz,
      );

  static Widget booking({required bool enabled}) => DashboardSvgIcon(
        asset: enabled ? AppAssets.icDashboardBooking : AppAssets.icDashboardBookingGrey,
        size: _sz,
      );

  static Widget reporting({required bool enabled}) => DashboardSvgIcon(
        asset: enabled ? AppAssets.icDashboardAlert : AppAssets.icDashboardAlertGrey,
        size: _sz,
      );
}
