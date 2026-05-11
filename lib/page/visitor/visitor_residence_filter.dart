import 'dart:convert';

import '../../core/dashboard_prefs.dart';

/// Android `VisitorActivity` / `RegisterGatePage` style `filterResidence` clause.
String buildVisitorResidenceFilterClause(DashboardSnapshot snap) {
  final id = snap.residenceId;
  if (id.isEmpty) return '';

  if (snap.isStrictBuildingOffice) {
    final parts = <String>["(residence_uuid='$id')"];
    final raw = snap.buildingResidencesJson.trim();
    if (raw.isNotEmpty && raw != 'null' && raw != '[]') {
      try {
        final list = jsonDecode(raw);
        if (list is List<dynamic>) {
          for (final item in list) {
            if (item is! Map) continue;
            final m = Map<String, dynamic>.from(item);
            final cu = m['company_uuid']?.toString();
            if (cu != null && cu.isNotEmpty) {
              parts.add("(residence_uuid='$cu')");
            }
          }
        }
      } catch (_) {}
    }
    return '(${parts.join(' OR ')})';
  }
  return "(residence_uuid='$id')";
}
