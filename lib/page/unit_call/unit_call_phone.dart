import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'unit_call_strings.dart';

Future<void> dialMembershipPhone(BuildContext context, String rawPhone) async {
  var phone = rawPhone.trim();
  if (phone.length <= 5) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(UnitCallStrings.noPhone)));
    }
    return;
  }
  final first = phone.substring(0, 1);
  if (first != '0' && first != '+') {
    phone = '+$phone';
  }
  final uri = Uri.parse('tel:$phone');
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
  } catch (_) {}
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(UnitCallStrings.cannotLaunchDialer)));
  }
}

void showVoipPlaceholder(BuildContext context) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text(UnitCallStrings.voipComingSoon)));
}
