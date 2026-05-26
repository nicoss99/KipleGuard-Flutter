import 'package:flutter/material.dart';

import '../page/reporting/reporting_strings.dart';
import 'app_success_dialog.dart';

Future<void> showGuardPinSuccessDialog(
  BuildContext context, {
  String? title,
  String? message,
}) {
  return showAppSuccessDialog(
    context,
    title: title ?? ReportingStrings.success,
    message: message ?? ReportingStrings.pinSuccessMessage,
  );
}
