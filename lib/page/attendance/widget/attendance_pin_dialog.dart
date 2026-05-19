import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../widget/guard_pin_dialog.dart';
import '../attendance_provider.dart';
import '../attendance_state.dart';
import '../../reporting/reporting_strings.dart';
import 'attendance_shift_success_dialog.dart';

/// Same PIN UX as reporting ([GuardPinDialog]): 6 cells, loading, success, error + try again.
abstract final class AttendancePinDialog {
  static Future<void> show({
    required BuildContext context,
    required BuildContext pageContext,
    required WidgetRef ref,
    required AttendanceShiftFlow flow,
  }) async {
    final outcome = await showDialog<GuardPinOutcome>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GuardPinDialog(
        defaultFailureText: ReportingStrings.pinNotFound,
        onVerify: (pin) async {
          final err = await ref.read(attendanceProvider.notifier).verifyPinAndPrepareShift(
                pin6: pin,
                flow: flow,
              );
          if (err != null) return GuardPinOutcome.failure(err);
          return const GuardPinOutcome.success();
        },
      ),
    );
    if (outcome == null || !outcome.ok) return;
    if (!pageContext.mounted) return;
    final messenger = ScaffoldMessenger.of(pageContext);
    final photoErr = await ref.read(attendanceProvider.notifier).capturePhotoAndSubmit();
    if (!pageContext.mounted) return;
    if (photoErr != null) {
      messenger.showSnackBar(SnackBar(content: Text(photoErr)));
      return;
    }
    await showAttendanceShiftSuccessDialog(pageContext, flow: flow);
  }
}
