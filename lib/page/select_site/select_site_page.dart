import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/dashboard_prefs.dart';
import '../../theme/app_color.dart';
import '../home/home_repository.dart';
import 'residence_choice.dart';
import 'residence_choices.dart';
import 'select_site_strings.dart';
import 'select_site_text_style.dart';
import 'widget/select_site_residence_tile.dart';

/// Android `ResidenceActivity` / `activity_selectresidence` — list from `GET data/residences` + roles.
class SelectSitePage extends ConsumerStatefulWidget {
  const SelectSitePage({super.key});

  @override
  ConsumerState<SelectSitePage> createState() => _SelectSitePageState();
}

class _SelectSitePageState extends ConsumerState<SelectSitePage> {
  List<ResidenceChoice> _choices = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(homeRepositoryProvider);
      var list = await loadResidenceChoicesSafe(repo);
      final snap = await DashboardPrefs.loadSnapshot();
      _sortChoices(list, snap.residenceId);
      if (mounted) {
        setState(() {
          _choices = list;
          _loading = false;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message ?? 'Network error';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Something went wrong';
        });
      }
    }
  }

  void _sortChoices(List<ResidenceChoice> list, String selectedId) {
    if (selectedId.isEmpty) {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return;
    }
    final sel = list.where((e) => e.uuid == selectedId).toList();
    final rest = list.where((e) => e.uuid != selectedId).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    list
      ..clear()
      ..addAll([...sel, ...rest]);
  }

  Future<void> _pick(ResidenceChoice c) async {
    await DashboardPrefs.writeResidenceSelection(
      residenceUuid: c.uuid,
      residenceName: c.name,
      coverUrl: c.coverUrl,
      callOption: c.callOption,
      intercomEnabled: c.intercom,
      attendance: c.attendance,
      visitors: c.visitors,
      reporting: c.reporting,
      booking: c.booking,
      securityCompanyUuid: c.securityUuid,
      qr: c.qr,
      officeType: c.officeType,
      frEnable: c.frEnable,
      buildingResidencesJson: c.buildingResidencesJson,
      hdf: c.hdf,
      healthCode: c.healthCode,
      quarantineDays: c.quarantineDays,
      normalTemp: c.normalTemp,
      lpr: c.lpr,
    );
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColor.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: AppColor.primary,
              child: SizedBox(height: top, width: double.infinity),
            ),
            Material(
              color: AppColor.white,
              elevation: 1,
              child: SizedBox(
                height: 50.h,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(false),
                      icon: Icon(Icons.arrow_back_ios_new, color: AppColor.primary, size: 20.sp),
                    ),
                    Expanded(
                      child: Text(
                        SelectSiteStrings.pageTitle,
                        textAlign: TextAlign.center,
                        style: SelectSiteTextStyle.appBarTitle(),
                      ),
                    ),
                    SizedBox(width: 48.w),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColor.primary))
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            SizedBox(height: 16.h),
                            TextButton(onPressed: _load, child: const Text('Retry')),
                          ],
                        ),
                      ),
                    )
                  : _choices.isEmpty
                  ? const Center(child: Text('No sites available'))
                  : RefreshIndicator(
                      color: AppColor.primary,
                      onRefresh: _load,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(bottom: bottom),
                        itemCount: _choices.length,
                        itemBuilder: (context, index) {
                          final c = _choices[index];
                          return SelectSiteResidenceTile(choice: c, onTap: () => _pick(c));
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
