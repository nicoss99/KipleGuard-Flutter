import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../theme/app_color.dart';
import '../../widget/modal_progress_hud.dart';
import 'home_provider.dart';
import 'widget/dashboard_bottom_bar.dart';
import 'widget/dashboard_header_bar.dart';
import 'widget/dashboard_hero_section.dart';
import 'widget/dashboard_module_grid.dart';

/// Port of Android `activity_dashboard.xml` / `DashboardActivity` shell UI.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(homeProvider);
    return ModalProgressHud(
      inAsyncCall: false,
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: Column(
          children: [
            const DashboardHeaderBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 12.h),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardHeroSection(),
                    DashboardModuleGrid(),
                  ],
                ),
              ),
            ),
            const DashboardBottomBar(),
          ],
        ),
      ),
    );
  }
}
