import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../theme/app_color.dart';
import '../../../widget/app_confirm_dialog.dart';
import '../profile_strings.dart';

/// Sign-out confirmation — kipleHomev2 `showSignOutDialog` (logout icon, red confirm).
void showSignOutDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AppConfirmDialog(
      icon: LucideIcons.log_out,
      iconColor: AppColor.errorStrong,
      iconBackgroundColor: AppColor.errorLight,
      title: ProfileStrings.signOut,
      message: ProfileStrings.signOutConfirmationMessage,
      confirmText: ProfileStrings.signOut,
      cancelText: ProfileStrings.cancel,
      confirmButtonColor: AppColor.errorStrong,
      onConfirm: onConfirm,
    ),
  );
}
