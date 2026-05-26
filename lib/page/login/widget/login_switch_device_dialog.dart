import 'package:flutter/material.dart';

import '../../../widget/app_confirm_dialog.dart';
import '../../auth/guard_models.dart';

/// Shows switch-device confirmation; returns `true` if user tapped Proceed.
Future<bool> showLoginSwitchDeviceDialog(
  BuildContext context, {
  required GuardSwitchDevice info,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AppConfirmDialog(
      title: 'Sign in',
      message: info.message,
      confirmText: 'Proceed',
      confirmResult: true,
      showCancel: true,
    ),
  );
  return result == true;
}
