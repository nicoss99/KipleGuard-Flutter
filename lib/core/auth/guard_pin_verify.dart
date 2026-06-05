import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../page/attendance/attendance_pin_validation.dart';
import '../../page/auth/guard_pin_verify_result.dart';
import '../../page/auth/guard_repository.dart';
import '../../page/reporting/reporting_pin_verifier.dart';
import '../../widget/guard_pin_dialog.dart';

Future<GuardPinOutcome> _guardPinOutcomeAfterApi({
  required String pin,
  required Future<GuardPinVerifyResult> Function(String pin) verifyPin,
  required Future<Object?> Function(String pin) resolve,
  String? defaultFailureText,
}) async {
  if (pin.length != 6) {
    return GuardPinOutcome.failure(defaultFailureText);
  }
  final result = await verifyPin(pin);
  if (!result.verified) {
    final apiMessage = result.message?.trim();
    return GuardPinOutcome.failure(
      apiMessage != null && apiMessage.isNotEmpty
          ? apiMessage
          : defaultFailureText,
    );
  }
  final value = await resolve(pin);
  if (value == null) {
    return GuardPinOutcome.failure(defaultFailureText);
  }
  return GuardPinOutcome.success(value);
}

/// Shows [GuardPinDialog] with `POST /api/v1/guard/auth/verify-pin`, then [resolveAfterVerify].
Future<GuardPinOutcome?> showApiGuardPinDialog({
  required BuildContext context,
  required WidgetRef ref,
  required Future<Object?> Function(String pin) resolveAfterVerify,
  String? defaultFailureText,
  bool barrierDismissible = false,
}) {
  final authRepo = ref.read(guardRepositoryProvider);
  return showDialog<GuardPinOutcome>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => GuardPinDialog(
      defaultFailureText: defaultFailureText,
      onVerify: (pin) => _guardPinOutcomeAfterApi(
        pin: pin,
        verifyPin: authRepo.verifyPin,
        resolve: resolveAfterVerify,
        defaultFailureText: defaultFailureText,
      ),
    ),
  );
}

Future<({String guardUuid, String companyUuid})?> verifyPinForAttendance({
  required Future<GuardPinVerifyResult> Function(String pin) verifyPin,
  required String securityJson,
  required String residenceUuid,
  required String pin6,
  String fallbackCompanyUuid = '',
}) async {
  final result = await verifyPin(pin6);
  if (!result.verified) return null;
  return matchGuardForResidence(
    securityJson: securityJson,
    residenceUuid: residenceUuid,
    pin6: pin6,
    fallbackCompanyUuid: fallbackCompanyUuid,
  );
}

Future<ReportingPinResult> verifyPinForReporting({
  required Future<GuardPinVerifyResult> Function(String pin) verifyPin,
  required String securityJson,
  required String residenceUuid,
  required String pin,
  String fallbackCompanyUuid = '',
}) async {
  final match = await verifyPinForAttendance(
    verifyPin: verifyPin,
    securityJson: securityJson,
    residenceUuid: residenceUuid,
    pin6: pin,
    fallbackCompanyUuid: fallbackCompanyUuid,
  );
  if (match == null) return const ReportingPinResult.failure();
  return ReportingPinResult.success(
    guardPin: pin,
    guardUuid: match.guardUuid,
    companyUuid:
        match.companyUuid.isNotEmpty ? match.companyUuid : fallbackCompanyUuid,
  );
}

/// Resolves attendance guard after API PIN verification.
Future<Object?> resolveAttendanceGuardAfterPin({
  required String pin,
  required String securityJson,
  required String residenceUuid,
  String fallbackCompanyUuid = '',
}) async =>
    matchGuardForResidence(
      securityJson: securityJson,
      residenceUuid: residenceUuid,
      pin6: pin,
      fallbackCompanyUuid: fallbackCompanyUuid,
    );

/// Resolves reporting payload after API PIN verification.
Future<Object?> resolveReportingGuardAfterPin({
  required String pin,
  required String securityJson,
  required String residenceUuid,
  String fallbackCompanyUuid = '',
}) async {
  final match = matchGuardForResidence(
    securityJson: securityJson,
    residenceUuid: residenceUuid,
    pin6: pin,
    fallbackCompanyUuid: fallbackCompanyUuid,
  );
  if (match == null) return null;
  return ReportingPinResult.success(
    guardPin: pin,
    guardUuid: match.guardUuid,
    companyUuid:
        match.companyUuid.isNotEmpty ? match.companyUuid : fallbackCompanyUuid,
  );
}
