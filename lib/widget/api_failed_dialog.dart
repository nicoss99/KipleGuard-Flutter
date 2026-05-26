import 'package:flutter/material.dart';

import '../core/api_error_message.dart';
import '../core/auth/session_expired_handler.dart';
import '../theme/app_color.dart';
import 'app_confirm_dialog.dart';

/// Single-action dialog when a guard/API request fails.
Future<void> showApiFailedDialog(
  BuildContext context, {
  Object? error,
  String? message,
  String title = 'Request failed',
}) {
  if (error != null && isSessionTerminationApiError(error)) {
    return Future<void>.value();
  }
  if (message != null &&
      (message.trim() == sessionSignedOutAnotherDeviceMessage.trim() ||
          message.toLowerCase().contains('logged in on another device'))) {
    return Future<void>.value();
  }
  final text = message ?? (error != null ? apiErrorMessage(error) : 'Something went wrong');
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AppConfirmDialog(
      icon: Icons.error_outline_rounded,
      iconColor: AppColor.errorStrong,
      iconBackgroundColor: AppColor.errorLight,
      title: title,
      message: text,
      showCancel: false,
      confirmText: 'OK',
    ),
  );
}
