import '../../core/guard_api_message.dart';
import 'guard_models.dart';

/// `GET api/v1/guard/residences` (optional `current_residence_uuid` query).
GuardResidencesResult parseGuardResidencesFromApi(Map<String, dynamic>? data) {
  if (data == null) {
    return const GuardResidencesResult(residences: []);
  }
  final currentMap = asStringKeyedMap(data['current_residence']);
  GuardResidence? current;
  if (currentMap != null) {
    final parsed = GuardResidence.fromJson(currentMap);
    if (parsed.uuid.isNotEmpty) current = parsed;
  }
  return GuardResidencesResult(
    currentResidence: current,
    residences: parseGuardResidencesList(data['residences']),
  );
}

List<GuardResidence> parseGuardResidencesList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(GuardResidence.fromJson)
      .where((r) => r.uuid.isNotEmpty)
      .toList();
}
