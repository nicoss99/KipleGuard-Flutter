import '../../core/app_config.dart';
import '../../core/app_flavor.dart';

/// Android `VisitorDetailsActivity` share body: residence name + `BASE_EPASS_URL` + QR payload.
String buildEpassShareMessage({
  required AppFlavor flavor,
  required String qrCode,
  required String residenceDisplayName,
}) {
  final link = buildEpassShareLink(flavor: flavor, qrCode: qrCode);
  final name = residenceDisplayName.trim().isEmpty ? 'this property' : residenceDisplayName.trim();
  return "Hi! You've registered as visitor at $name. Please use this link to fill up HDF form and get "
      'the QR code to access the property.\n\n$link';
}

/// Full e-pass URL for the visitor QR token (same pattern as native `BASE_EPASS_URL/$QRcode`).
String buildEpassShareLink({required AppFlavor flavor, required String qrCode}) {
  var base = AppConfig.epassBaseUrl(flavor).trim();
  final code = qrCode.trim();
  if (code.isEmpty) return base;
  while (base.endsWith('/')) {
    base = base.substring(0, base.length - 1);
  }
  return '$base/$code';
}
