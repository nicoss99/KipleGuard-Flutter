import '../../core/unit_call_session_prefs.dart';
import 'unit_call_models.dart';
import 'unit_call_parser.dart';
import 'unit_call_state.dart';

/// Re-applies last session for the same residence (after cache / network reload).
Future<UnitCallState> mergeStoredUnitCallSession(UnitCallState state) async {
  final raw = await UnitCallSessionPrefs.read();
  if (raw == null) return state;
  if (raw['residenceUuid']?.toString() != state.residenceUuid) return state;
  final officeSaved = raw['officeMode'] == true;
  if (officeSaved != state.officeMode) return state;

  final expanded = <String>{};
  final list = raw['expandedIds'];
  if (list is List<dynamic>) {
    for (final e in list) {
      final id = e.toString();
      if (state.units.any((u) => u.id == id)) expanded.add(id);
    }
  }
  final search = raw['searchQuery']?.toString() ?? '';

  if (state.officeMode) {
    return state.copyWith(searchQuery: search, expandedUnitIds: expanded);
  }

  final stepIdx = (raw['step'] as num?)?.toInt() ?? 0;
  final step = UnitCallStep.values[stepIdx.clamp(0, UnitCallStep.values.length - 1)];
  final blockRaw = raw['selectedBlock']?.toString();
  final floorRaw = raw['selectedFloor']?.toString();

  if (step == UnitCallStep.blocks || blockRaw == null || blockRaw.isEmpty) {
    return state.copyWith(
      step: UnitCallStep.blocks,
      searchQuery: '',
      expandedUnitIds: {},
      floors: const [],
      clearSelectedBlock: true,
      clearSelectedFloor: true,
    );
  }

  String? blockMatch;
  for (final b in state.blocks) {
    if (b.toUpperCase() == blockRaw.toUpperCase()) {
      blockMatch = b;
      break;
    }
  }
  if (blockMatch == null) return state;

  final fl = floorsForBlock(state.units, blockMatch);
  if (step == UnitCallStep.floors) {
    return state.copyWith(
      step: UnitCallStep.floors,
      selectedBlock: blockMatch,
      floors: fl,
      searchQuery: '',
      expandedUnitIds: {},
      clearSelectedFloor: true,
    );
  }

  UnitFloorOption? floorMatch;
  final floorKey = (floorRaw ?? '').toUpperCase();
  for (final f in fl) {
    if (f.name.toUpperCase() == floorKey) {
      floorMatch = f;
      break;
    }
  }
  if (floorMatch == null) {
    return state.copyWith(
      step: UnitCallStep.floors,
      selectedBlock: blockMatch,
      floors: fl,
      searchQuery: '',
      expandedUnitIds: {},
      clearSelectedFloor: true,
    );
  }

  return state.copyWith(
    step: UnitCallStep.units,
    selectedBlock: blockMatch,
    selectedFloor: floorMatch.name,
    floors: fl,
    searchQuery: search,
    expandedUnitIds: expanded,
  );
}
