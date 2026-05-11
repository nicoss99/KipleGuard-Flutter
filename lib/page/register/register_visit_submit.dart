import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api_error_message.dart';
import '../../core/app_logger.dart';
import '../../core/dashboard_prefs.dart';
import '../../theme/app_text_style.dart';
import 'register_models.dart';
import 'register_payload.dart';
import 'register_repository.dart';
import 'register_strings.dart';
import 'register_visitor_draft.dart';
import 'widget/register_time_field.dart';

Future<void> submitRegisterVisit({
  required WidgetRef ref,
  required BuildContext context,
  required String residenceUuid,
  required RegisterVisitorTypeOption type,
  required RegisterUnitOption unit,
  required RegisterHostOption? host,
  required RegisterVisitorDraft visitor,
  required String passReference,
  required DateTime startUtc,
  required DateTime? endUtc,
  required List<String> walkinPhotoUuids,
}) async {
  final startStr = formatUtcApi(startUtc);
  final endStr = endUtc == null ? null : formatUtcApi(endUtc);
  final payload = await buildRegisterVisitorPayload(
    residenceUuid: residenceUuid,
    visitorType: type,
    unit: unit,
    visitor: visitor,
    passReference: passReference,
    startTimeUtc: startStr,
    endTimeUtc: endStr == startStr ? null : endStr,
    host: host,
    walkinPhotoUuids: walkinPhotoUuids,
  );
  final repo = ref.read(registerRepositoryProvider);
  final body = await repo.registerVisitor(payload);
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
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(RegisterStrings.success, style: AppTextStyle.title),
      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
    ),
  );
  if (context.mounted) context.pop();
}

void handleRegisterSubmitError(BuildContext context, Object e, StackTrace st) {
  if (e is DioException) {
    AppLog.error('Register submit failed', tag: 'Register', error: e, stackTrace: st);
    final msg = apiErrorMessage(e);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    return;
  }
  AppLog.error('Register submit failed', tag: 'Register', error: e, stackTrace: st);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Something went wrong')));
  }
}
