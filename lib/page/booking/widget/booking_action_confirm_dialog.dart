import 'package:flutter/material.dart';

import '../../../theme/app_color.dart';
import '../../../widget/app_confirm_dialog.dart';
import '../booking_strings.dart';

/// Check-in / check-out confirmation — same layout as [showSignOutDialog].
Future<bool> showBookingActionConfirmDialog(
  BuildContext context, {
  required bool checkIn,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AppConfirmDialog(
      icon: checkIn ? Icons.login_rounded : Icons.logout_rounded,
      iconColor: checkIn ? AppColor.primary : AppColor.errorStrong,
      iconBackgroundColor: checkIn
          ? AppColor.primary.withValues(alpha: 0.12)
          : AppColor.errorLight,
      title: checkIn ? BookingStrings.checkIn : BookingStrings.checkOut,
      message: checkIn ? BookingStrings.confirmCheckIn : BookingStrings.confirmCheckOut,
      confirmText: checkIn ? BookingStrings.checkIn : BookingStrings.checkOut,
      cancelText: BookingStrings.cancel,
      confirmButtonColor: checkIn ? AppColor.primary : AppColor.errorStrong,
      confirmResult: true,
    ),
  );
  return result == true;
}
