import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/dashboard_prefs.dart';
import '../../router/app_route.dart' show AppPaths;
import '../../widget/app_progress_indicator.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import 'register_models.dart';
import 'register_parsers.dart';
import 'register_strings.dart';
import 'widget/register_building_tile.dart';
import 'widget/register_page_scaffold.dart';

/// Android `ListBuildingResidenceActivity` or direct `CreateVisitActivity` when not strict building.
class RegisterGatePage extends StatefulWidget {
  const RegisterGatePage({super.key});

  @override
  State<RegisterGatePage> createState() => _RegisterGatePageState();
}

class _RegisterGatePageState extends State<RegisterGatePage> {
  bool _loading = true;
  List<RegisterBuildingRow> _buildings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snap = await DashboardPrefs.loadSnapshot();
    final buildings = parseBuildingRows(snap.buildingResidencesJson);
    if (!mounted) return;
    if (snap.isStrictBuildingOffice && buildings.isNotEmpty) {
      setState(() {
        _buildings = buildings;
        _loading = false;
      });
      return;
    }
    if (snap.residenceId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    if (!mounted) return;
    context.replace(AppPaths.registerVisit(snap.residenceId));
  }

  @override
  Widget build(BuildContext context) {
    return RegisterPageScaffold(
      title: RegisterStrings.title,
      onBack: () => context.pop(),
      child: _loading
          ? const Center(child: AppProgressIndicator())
          : _buildings.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text('No residence selected', style: AppTextStyle.bodyMuted, textAlign: TextAlign.center),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: AppSpacing.md),
              itemCount: _buildings.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (context, i) {
                final row = _buildings[i];
                return RegisterBuildingTile(
                  name: row.name,
                  onTap: () => context.push(AppPaths.registerVisit(row.companyUuid)),
                );
              },
            ),
    );
  }
}
