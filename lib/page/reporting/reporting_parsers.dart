import 'dart:convert';

import '../../core/guard_api_message.dart';
import 'reporting_models.dart';

List<ReportingCategory> parseIncidentTypesFromApi(Map<String, dynamic>? body) {
  final data = guardApiData(body);
  final raw = data?['incident_types'];
  if (raw is! List<dynamic>) return [];
  final out = <ReportingCategory>[];
  for (final item in raw) {
    if (item is! Map<String, dynamic>) continue;
    final key = item['key']?.toString() ?? '';
    final label = item['label']?.toString() ?? '';
    if (key.isEmpty || label.isEmpty) continue;
    out.add(ReportingCategory(key: key, label: label));
  }
  return out;
}

String encodeIncidentTypesCache(List<ReportingCategory> list) => jsonEncode(
      list.map((c) => <String, String>{'key': c.key, 'label': c.label}).toList(),
    );

List<ReportingCategory> parseIncidentTypesCache(String raw) {
  if (raw.trim().isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(
          (m) => ReportingCategory(
            key: m['key']?.toString() ?? '',
            label: m['label']?.toString() ?? '',
          ),
        )
        .where((c) => c.key.isNotEmpty && c.label.isNotEmpty)
        .toList();
  } catch (_) {
    return [];
  }
}
