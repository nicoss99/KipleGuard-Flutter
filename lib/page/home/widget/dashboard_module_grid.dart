import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../dashboard_strings.dart';
import 'dashboard_module_card.dart';

/// Two-column tiles matching `activity_dashboard.xml` `homeView1` / `homeView2`.
class DashboardModuleGrid extends StatelessWidget {
  const DashboardModuleGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.95,
        children: [
          DashboardModuleCard(
            icon: Icons.calendar_month,
            title: DashboardStrings.attendance,
            subtitle: DashboardStrings.kehadiran,
          ),
          DashboardModuleCard(
            icon: Icons.person,
            title: DashboardStrings.visitor,
            subtitle: DashboardStrings.pelawat,
          ),
          DashboardModuleCard(
            icon: Icons.event_note,
            title: DashboardStrings.booking,
            subtitle: DashboardStrings.tempahan,
          ),
          DashboardModuleCard(
            icon: Icons.warning_amber_rounded,
            title: DashboardStrings.reporting,
            subtitle: DashboardStrings.laporan,
          ),
        ],
      ),
    );
  }
}
