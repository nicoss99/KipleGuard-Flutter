import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../page/attendance/attendance_pin_validation.dart';
import '../../page/auth/guard_pin_verify_result.dart';
import '../../page/auth/guard_repository.dart';
import '../../page/reporting/reporting_pin_verifier.dart';
import '../../widget/guard_pin_dialog.dart';

Future<GuardPinOutcome> _guardPinOutcomeAfterApi({
  required String pin,
  required Future<GuardPinVerifyResult> Function(
    String pin, {
    required String residenceUuid,
  }) verifyPin,
  required String residenceUuid,
  required Future<Object?> Function(String pin, GuardPinVerifyResult result)
      resolve,
  String? defaultFailureText,
}) async {
  if (pin.length != 6) {
    return GuardPinOutcome.failure(defaultFailureText);
  }
  final result = await verifyPin(pin, residenceUuid: residenceUuid);
  if (!result.verified) {
    final apiMessage = result.message?.trim();
    return GuardPinOutcome.failure(
      apiMessage != null && apiMessage.isNotEmpty
          ? apiMessage
          : defaultFailureText,
    );
  }
  final value = await resolve(pin, result);
  return GuardPinOutcome.success(value);
}

/// Shows [GuardPinDialog] with `POST /api/v1/guard/auth/verify-pin`, then [resolveAfterVerify].
Future<GuardPinOutcome?> showApiGuardPinDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String residenceUuid,
  required Future<Object?> Function(String pin, GuardPinVerifyResult result)
      resolveAfterVerify,
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
        residenceUuid: residenceUuid,
        verifyPin: authRepo.verifyPin,
        resolve: resolveAfterVerify,
        defaultFailureText: defaultFailureText,
      ),
    ),
  );
}

Future<({String guardUuid, String companyUuid})?> verifyPinForAttendance({
  required Future<GuardPinVerifyResult> Function(
    String pin, {
    required String residenceUuid,
  }) verifyPin,
  required String securityJson,
  required String residenceUuid,
  required String pin6,
  String fallbackCompanyUuid = '',
}) async {
  final result = await verifyPin(pin6, residenceUuid: residenceUuid);
  if (!result.verified) return null;
  return resolveGuardAfterApiPin(
    securityJson: securityJson,
    residenceUuid: residenceUuid,
    pin6: pin6,
    fallbackCompanyUuid: fallbackCompanyUuid,
    apiIdentity: result.identity,
  );
}

Future<ReportingPinResult> verifyPinForReporting({
  required Future<GuardPinVerifyResult> Function(
    String pin, {
    required String residenceUuid,
  }) verifyPin,
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
  GuardPinVerifyResult? verifyResult,
}) async {
  final match = resolveGuardAfterApiPin(
    securityJson: securityJson,
    residenceUuid: residenceUuid,
    pin6: pin,
    fallbackCompanyUuid: fallbackCompanyUuid,
    apiIdentity: verifyResult?.identity,
  );
  return (
    guardUuid: match.guardUuid,
    companyUuid: match.companyUuid,
    pin: pin,
  );
}

/// Resolves reporting payload after API PIN verification.
Future<Object?> resolveReportingGuardAfterPin({
  required String pin,
  required String securityJson,
  required String residenceUuid,
  String fallbackCompanyUuid = '',
  GuardPinVerifyResult? verifyResult,
}) async {
  final match = resolveGuardAfterApiPin(
    securityJson: securityJson,
    residenceUuid: residenceUuid,
    pin6: pin,
    fallbackCompanyUuid: fallbackCompanyUuid,
    apiIdentity: verifyResult?.identity,
  );
  return ReportingPinResult.success(
    guardPin: pin,
    guardUuid: match.guardUuid,
    companyUuid:
        match.companyUuid.isNotEmpty ? match.companyUuid : fallbackCompanyUuid,
  );
}
