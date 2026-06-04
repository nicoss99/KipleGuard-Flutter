import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/dashboard_prefs.dart';
import '../../router/app_route.dart';
import '../../theme/app_color.dart';
import 'reporting_models.dart';
import 'reporting_pin_verifier.dart';
import 'reporting_strings.dart';
import '../../widget/guard_pin_dialog.dart';
import '../../widget/standard_primary_header.dart';

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
    final outcome = await showDialog<GuardPinOutcome>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GuardPinDialog(
        onVerify: (pin) async {
          final snap = await DashboardPrefs.loadSnapshot();
          final r = verifyGuardPin(
            securityJson: snap.securityJson,
            residenceUuid: snap.residenceId,
            pin: pin,
            fallbackCompanyUuid: snap.securityUuid,
          );
          if (r.ok) return GuardPinOutcome.success(r);
          return const GuardPinOutcome.failure();
        },
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
