import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../widget/api_failed_dialog.dart';
import '../../core/app_logger.dart';
import '../../core/dashboard_prefs.dart';
import 'register_models.dart';
import 'register_payload.dart';
import 'register_repository.dart';
import 'register_visitor_draft.dart';
import 'widget/register_success_dialog.dart';

Future<void> submitRegisterVisit({
  required WidgetRef ref,
  required BuildContext context,
  required String residenceUuid,
  required RegisterVisitorTypeOption type,
  required RegisterUnitOption unit,
  required RegisterHostOption? host,
  required RegisterVisitorDraft visitor,
  required String passReference,
  required List<XFile> visitPhotos,
}) async {
  final primaryPhoto = visitPhotos.first;
  final purpose = visitor.company.trim().isEmpty
      ? 'Guard registration'
      : visitor.company.trim();
  final payload = await buildRegisterVisitorPayload(
    visitorType: type,
    unit: unit,
    visitor: visitor,
    passReference: passReference,
    purpose: purpose,
    photoPath: primaryPhoto.path,
    host: host,
  );
  final repo = ref.read(registerRepositoryProvider);
  final body = await repo.registerVisitor(
    scopeUuid: residenceUuid,
    body: payload,
  );
  final visitorUuid = parseVisitorUuidFromRegisterResponse(body);
  final snap = await DashboardPrefs.loadSnapshot();
  if (snap.qr && visitorUuid != null) {
    await repo.addVisitorAccessCard(
      visitorUuid: visitorUuid,
      visitorTypeUuid: type.uuid,
      residenceUuid: residenceUuid,
      unitUuid: unit.unitUuid,
    );
  }
  if (!context.mounted) return;
  final unitLabel = unit.blockName.trim().isEmpty
      ? unit.unitName
      : '${unit.blockName} · ${unit.unitName}';
  await showRegisterSuccessDialog(
    context,
    visitorName: visitor.name,
    unitLabel: unitLabel,
    visitTypeName: type.name,
  );
  if (context.mounted) context.pop();
}

Future<void> handleRegisterSubmitError(
  BuildContext context,
  Object e,
  StackTrace st,
) async {
  if (e is DioException) {
    AppLog.error('Register submit failed', tag: 'Register', error: e, stackTrace: st);
    if (context.mounted) {
      await showApiFailedDialog(context, error: e);
    }
    return;
  }
  AppLog.error('Register submit failed', tag: 'Register', error: e, stackTrace: st);
  if (context.mounted) {
    await showApiFailedDialog(context, message: 'Something went wrong');
  }
}
