import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_assets.dart';
import 'dashboard_tile_icon.dart';

/// Dashboard grid module icons (3D PNG — color when enabled, grey when disabled).
class DashboardTileIcons {
  static double get _sz => 56.w;

  static DashboardTileIcon attendance({required bool enabled}) => DashboardTileIcon(
        asset: enabled ? AppAssets.icDashboardAttendance : AppAssets.icDashboardAttendanceGrey,
        size: _sz,
      );

  static DashboardTileIcon visitor({required bool enabled}) => DashboardTileIcon(
        asset: enabled ? AppAssets.icDashboardVisitor : AppAssets.icDashboardVisitorGrey,
        size: _sz,
      );

  static DashboardTileIcon booking({required bool enabled}) => DashboardTileIcon(
        asset: enabled ? AppAssets.icDashboardBooking : AppAssets.icDashboardBookingGrey,
        size: _sz,
      );

  static DashboardTileIcon reporting({required bool enabled}) => DashboardTileIcon(
        asset: enabled ? AppAssets.icDashboardReporting : AppAssets.icDashboardReportingGrey,
        size: _sz,
      );
}
