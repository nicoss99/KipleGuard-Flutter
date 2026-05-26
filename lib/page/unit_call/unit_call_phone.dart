import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_logger.dart';
import '../../widget/api_failed_dialog.dart';
import 'unit_call_strings.dart';

/// Strips formatting; keeps leading `+` and digits (matches visitor detail dial).
String normalizeDialPhone(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';

  final buffer = StringBuffer();
  for (var i = 0; i < trimmed.length; i++) {
    final c = trimmed[i];
    if (c == '+' && buffer.isEmpty) {
      buffer.write(c);
    } else if (RegExp(r'\d').hasMatch(c)) {
      buffer.write(c);
    }
  }

  var phone = buffer.toString();
  if (phone.length <= 5) return '';
  if (!phone.startsWith('0') && !phone.startsWith('+')) {
    phone = '+$phone';
  }
  return phone;
}

Future<void> dialMembershipPhone(BuildContext context, String rawPhone) async {
  final phone = normalizeDialPhone(rawPhone);
  if (phone.length <= 5) {
    if (context.mounted) {
      await showApiFailedDialog(context, message: UnitCallStrings.noPhone);
    }
    return;
  }

  final uri = Uri.parse('tel:$phone');
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launched) return;
  } catch (e, st) {
    AppLog.error('Dial failed', tag: 'UnitCall', error: e, stackTrace: st);
  }
  if (context.mounted) {
    await showApiFailedDialog(context, message: UnitCallStrings.cannotLaunchDialer);
  }
}

Future<void> showVoipPlaceholder(BuildContext context) async {
  if (!context.mounted) return;
  await showApiFailedDialog(context, message: UnitCallStrings.voipComingSoon);
}
