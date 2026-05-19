import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_logger.dart';
import '../../core/auth_prefs.dart';
import '../../core/dashboard_prefs.dart';
import '../../router/app_route.dart';
import '../select_site/residence_choice.dart';
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import '../../widget/modal_progress_hud.dart';
import 'dashboard_header_title.dart';
import 'dashboard_strings.dart';
import 'home_provider.dart';
import 'widget/dashboard_bottom_bar.dart';
import 'widget/dashboard_header_bar.dart';
import 'widget/dashboard_hero_section.dart';
import 'widget/dashboard_module_grid.dart';

/// Port of Android `activity_dashboard.xml` / `DashboardActivity` shell UI.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).onAppear();
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showNoRoleDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(DashboardStrings.appTitle, style: AppTextStyle.title),
        content: Text(DashboardStrings.noRolesAuthorized, style: AppTextStyle.body),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              ref.read(homeProvider.notifier).acknowledgeNoRoleDialog();
              await AuthPrefs.clearSession();
              if (mounted) context.go(AppRoute.login.path);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    ref.listen(homeProvider, (prev, next) {
      if (next.triggerNoRoleDialog && (prev?.triggerNoRoleDialog != true)) {
        _showNoRoleDialog();
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColor.lightGreyBar,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: ModalProgressHud(
        inAsyncCall: state.refreshing,
        child: Scaffold(
          backgroundColor: AppColor.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: AppColor.primary,
                child: SizedBox(height: topInset, width: double.infinity),
              ),
              DashboardHeaderBar(
                title: DashboardHeaderTitle.format(state.residenceTitle),
                onTitleTap: () async {
                  final router = GoRouter.of(context);
                  final snap = await DashboardPrefs.loadSnapshot();
                  if (!mounted) return;
                  final picked = await router.push<ResidenceChoice?>(
                    AppRoute.selectSite.path,
                  );
                  if (!mounted || picked == null) return;
                  await ref.read(homeProvider.notifier).applySiteSelection(
                        picked,
                        previousResidenceId: snap.residenceId,
                        previousSecurityUuid: snap.securityUuid,
                      );
                },
              ),
              if (state.loadError != null)
                Material(
                  color: AppColor.orange.withValues(alpha: 0.12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.loadError!,
                            style: AppTextStyle.body.copyWith(color: AppColor.textPrimary, fontSize: 13.sp),
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref.read(homeProvider.notifier).refreshFromRemote(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColor.primary,
                  onRefresh: () => ref.read(homeProvider.notifier).refreshFromRemote(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardHeroSection(
                          userName: state.userName,
                          userEmail: state.userEmail,
                          profileInitial: state.profileInitial,
                          qrEnabled: state.qrEnabled,
                          onViewQr: state.qrEnabled
                              ? () {
                                  AppLog.track('view_qr_tap', screen: 'Home');
                                  _snack('View QR — coming soon');
                                }
                              : null,
                        ),
                        DashboardModuleGrid(
                          attendanceEnabled: state.attendanceEnabled,
                          visitorEnabled: state.visitorEnabled,
                          bookingEnabled: state.bookingEnabled,
                          reportEnabled: state.reportEnabled,
                          onDisabledFeature: _snack,
                          onVisitorEnabledTap: () {
                            AppLog.track('visitor_grid', screen: 'Home');
                            context.push(AppRoute.visitor.path);
                          },
                          onAttendanceEnabledTap: () {
                            AppLog.track('attendance_grid', screen: 'Home');
                            context.push(AppRoute.attendance.path);
                          },
                          onBookingEnabledTap: () {
                            AppLog.track('booking_grid', screen: 'Home');
                            context.push(AppRoute.booking.path);
                          },
                          onReportingEnabledTap: () {
                            AppLog.track('reporting_grid', screen: 'Home');
                            context.push(AppRoute.reporting.path);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: DashboardBottomBar(
                  intercomEnabled: state.intercomEnabled,
                  visitorEnabled: state.visitorEnabled,
                  onCall: () {
                    if (!state.intercomEnabled) {
                      _snack(DashboardStrings.featureCall);
                      return;
                    }
                    AppLog.track('call_main', screen: 'Home');
                    context.push(AppRoute.callUnits.path);
                  },
                  onRegister: () {
                    if (!state.visitorEnabled) {
                      _snack(DashboardStrings.featureVisitor);
                      return;
                    }
                    AppLog.track('register_main', screen: 'Home');
                    context.push(AppRoute.register.path);
                  },
                  onScan: () {
                    AppLog.track('scan_main', screen: 'Home');
                    context.push(AppRoute.scanQr.path);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
