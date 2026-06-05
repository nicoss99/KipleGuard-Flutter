import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/auth/guard_pin_verify.dart';
import '../../../core/dashboard_prefs.dart';
import '../../../widget/api_failed_dialog.dart';
import '../../home/home_repository.dart';
import '../attendance_provider.dart';
import '../attendance_state.dart';
import '../attendance_strings.dart';
import 'attendance_shift_success_dialog.dart';

/// Android `AttendanceActivity`: PIN → filter open shift → camera → submit.
abstract final class AttendanceShiftDialog {
  static Future<void> show({
    required BuildContext context,
    required BuildContext pageContext,
    required WidgetRef ref,
    required AttendanceShiftFlow flow,
  }) async {
    var snap = await DashboardPrefs.loadSnapshot();
    if (snap.securityUuid.trim().isNotEmpty && snap.securityJson.trim().isEmpty) {
      try {
        final repo = ref.read(homeRepositoryProvider);
        final raw = await repo.fetchGuardPinJson(snap.securityUuid.trim());
        await DashboardPrefs.setSecurityJson(repo.trimGuardPinPayload(raw));
        snap = await DashboardPrefs.loadSnapshot();
      } catch (_) {}
    }
    if (!context.mounted) return;
    if (snap.residenceId.trim().isEmpty) {
      if (pageContext.mounted) {
        await showApiFailedDialog(
          pageContext,
          message: AttendanceStrings.noResidenceSelected,
        );
      }
      return;
    }
    final pinOutcome = await showApiGuardPinDialog(
      context: context,
      ref: ref,
      resolveAfterVerify: (pin, result) => resolveAttendanceGuardAfterPin(
        pin: pin,
        securityJson: snap.securityJson,
        residenceUuid: snap.residenceId,
        fallbackCompanyUuid: snap.securityUuid,
        verifyResult: result,
      ),
    );
    if (pinOutcome?.ok != true || !pageContext.mounted) return;
    final verified = pinOutcome!.value;
    if (verified is! ({String guardUuid, String companyUuid})) return;

    final prepErr = await ref
        .read(attendanceProvider.notifier)
        .prepareShift(flow, guardUuid: verified.guardUuid);
    if (!pageContext.mounted) return;
    if (prepErr != null) {
      await showApiFailedDialog(pageContext, message: prepErr);
      return;
    }

    final photoErr = await ref.read(attendanceProvider.notifier).capturePhotoAndSubmit();
    if (!pageContext.mounted) return;
    if (photoErr != null) {
      await showApiFailedDialog(pageContext, message: photoErr);
      return;
    }

    await showAttendanceShiftSuccessDialog(pageContext, flow: flow);
  }
}
