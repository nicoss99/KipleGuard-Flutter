import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../dashboard_strings.dart';
import 'dashboard_module_card.dart';
import 'dashboard_tile_icons.dart';

/// Two-column tiles matching reference dashboard grid.
class DashboardModuleGrid extends StatelessWidget {
  const DashboardModuleGrid({
    super.key,
    required this.attendanceEnabled,
    required this.visitorEnabled,
    required this.bookingEnabled,
    required this.reportEnabled,
    required this.onDisabledFeature,
    required this.onVisitorEnabledTap,
  });

  final bool attendanceEnabled;
  final bool visitorEnabled;
  final bool bookingEnabled;
  final bool reportEnabled;
  final void Function(String message) onDisabledFeature;
  final VoidCallback onVisitorEnabledTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, left: 4.w, right: 4.w),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.08,
        children: [
          DashboardModuleCard(
            icon: DashboardTileIcons.attendance(enabled: attendanceEnabled),
            title: DashboardStrings.attendance,
            subtitle: DashboardStrings.kehadiran,
            enabled: attendanceEnabled,
            onTap: () {
              if (!attendanceEnabled) {
                onDisabledFeature(DashboardStrings.featureAttendance);
                return;
              }
            },
          ),
          DashboardModuleCard(
            icon: DashboardTileIcons.visitor(enabled: visitorEnabled),
            title: DashboardStrings.visitor,
            subtitle: DashboardStrings.pelawat,
            enabled: visitorEnabled,
            onTap: () {
              if (!visitorEnabled) {
                onDisabledFeature(DashboardStrings.featureVisitor);
                return;
              }
              onVisitorEnabledTap();
            },
          ),
          DashboardModuleCard(
            icon: DashboardTileIcons.booking(enabled: bookingEnabled),
            title: DashboardStrings.booking,
            subtitle: DashboardStrings.tempahan,
            enabled: bookingEnabled,
            onTap: () {
              if (!bookingEnabled) {
                onDisabledFeature(DashboardStrings.featureBooking);
                return;
              }
            },
          ),
          DashboardModuleCard(
            icon: DashboardTileIcons.reporting(enabled: reportEnabled),
            title: DashboardStrings.reporting,
            subtitle: DashboardStrings.laporan,
            enabled: reportEnabled,
            onTap: () {
              if (!reportEnabled) {
                onDisabledFeature(DashboardStrings.featureReport);
                return;
              }
            },
          ),
        ],
      ),
    );
  }
}
