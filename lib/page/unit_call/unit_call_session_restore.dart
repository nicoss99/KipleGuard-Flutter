import '../../core/unit_call_session_prefs.dart';
import 'unit_call_state.dart';

/// Reads saved block / floor / step for [UnitCallNotifier] to refetch via guard APIs.
Future<UnitCallSessionRestore?> readUnitCallSessionRestore(String residenceUuid) async {
  final raw = await UnitCallSessionPrefs.read();
  if (raw == null) return null;
  if (raw['residenceUuid']?.toString() != residenceUuid) return null;

  final stepIdx = (raw['step'] as num?)?.toInt() ?? 0;
  final step = UnitCallStep.values[stepIdx.clamp(0, UnitCallStep.values.length - 1)];

  return UnitCallSessionRestore(
    officeMode: raw['officeMode'] == true,
    step: step,
    selectedBlock: raw['selectedBlock']?.toString(),
    selectedFloor: raw['selectedFloor']?.toString(),
    searchQuery: raw['searchQuery']?.toString() ?? '',
    expandedIds: _expandedIds(raw['expandedIds']),
  );
}

Set<String> _expandedIds(dynamic raw) {
  if (raw is! List<dynamic>) return {};
  return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toSet();
}

class UnitCallSessionRestore {
  const UnitCallSessionRestore({
    required this.officeMode,
    required this.step,
    this.selectedBlock,
    this.selectedFloor,
    required this.searchQuery,
    required this.expandedIds,
  });

  final bool officeMode;
  final UnitCallStep step;
  final String? selectedBlock;
  final String? selectedFloor;
  final String searchQuery;
  final Set<String> expandedIds;
}
