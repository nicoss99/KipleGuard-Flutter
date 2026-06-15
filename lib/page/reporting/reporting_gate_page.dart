import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/auth/guard_pin_verify.dart';
import '../../core/dashboard_prefs.dart';
import '../../page/home/home_repository.dart';
import '../../router/app_route.dart';
import '../../theme/app_color.dart';
import '../../widget/standard_primary_header.dart';
import 'reporting_models.dart';
import 'reporting_pin_verifier.dart';
import 'reporting_strings.dart';

/// Android `ReportingStep1Activity` — header + guard PIN dialog.
class ReportingGatePage extends ConsumerStatefulWidget {
  const ReportingGatePage({super.key});

  @override
  ConsumerState<ReportingGatePage> createState() => _ReportingGatePageState();
}

class _ReportingGatePageState extends ConsumerState<ReportingGatePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPin());
  }

  Future<void> _openPin() async {
    var snap = await DashboardPrefs.loadSnapshot();
    if (snap.securityUuid.trim().isNotEmpty && snap.securityJson.trim().isEmpty) {
      try {
        final repo = ref.read(homeRepositoryProvider);
        final raw = await repo.fetchGuardPinJson(snap.securityUuid.trim());
        await DashboardPrefs.setSecurityJson(repo.trimGuardPinPayload(raw));
        snap = await DashboardPrefs.loadSnapshot();
      } catch (_) {}
    }
    if (!mounted) return;
    final outcome = await showApiGuardPinDialog(
      context: context,
      ref: ref,
      residenceUuid: snap.residenceId,
      resolveAfterVerify: (pin, result) => resolveReportingGuardAfterPin(
        pin: pin,
        securityJson: snap.securityJson,
        residenceUuid: snap.residenceId,
        fallbackCompanyUuid: snap.securityUuid,
        verifyResult: result,
      ),
    );
    if (!mounted) return;
    final payload = outcome?.value;
    if (outcome != null && outcome.ok && payload is ReportingPinResult) {
      final r = payload;
      context.pushReplacement(
        AppRoute.reportingForm.path,
        extra: ReportingFormArgs(
          guardPin: r.guardPin,
          guardUuid: r.guardUuid,
          companyUuid: r.companyUuid,
        ),
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: Column(
          children: [
            StandardPrimaryHeader(
              title: ReportingStrings.reportIncident,
              onBack: () => context.pop(),
            ),
            const Expanded(child: SizedBox.expand()),
          ],
        ),
      ),
    );
  }
}
