import '../../page/unit_call/unit_call_models.dart';
import 'app_cache_store.dart';
import 'guard_cache_keys.dart';

/// Persisted unit-call directory (blocks / floors / units + hosts).
class UnitCallDirectoryCache {
  const UnitCallDirectoryCache({
    required this.savedAt,
    required this.officeMode,
    required this.blocks,
    required this.floorsByBlock,
    required this.unitsByBlockFloor,
    required this.officeUnits,
  });

  final DateTime savedAt;
  final bool officeMode;
  final List<String> blocks;
  final Map<String, List<UnitFloorOption>> floorsByBlock;
  final Map<String, List<CallUnitRow>> unitsByBlockFloor;
  final List<CallUnitRow> officeUnits;
}

abstract final class GuardUnitCallCache {
  static Future<void> save({
    required String residenceUuid,
    required bool officeMode,
    required List<String> blocks,
    required Map<String, List<UnitFloorOption>> floorsByBlock,
    required Map<String, List<CallUnitRow>> unitsByBlockFloor,
    required List<CallUnitRow> officeUnits,
  }) async {
    if (residenceUuid.isEmpty) return;
    await AppCacheStore.write(
      GuardCacheKeys.unitCallDirectory(residenceUuid),
      <String, dynamic>{
        'officeMode': officeMode,
        'blocks': blocks,
        'floorsByBlock': floorsByBlock.map(
          (k, v) => MapEntry(k, v.map((f) => {'name': f.name, 'block': f.block}).toList()),
        ),
        'unitsByBlockFloor': unitsByBlockFloor.map(
          (k, v) => MapEntry(k, v.map((u) => u.toCacheJson()).toList()),
        ),
        'officeUnits': officeUnits.map((u) => u.toCacheJson()).toList(),
      },
    );
  }

  static Future<UnitCallDirectoryCache?> read(String residenceUuid) async {
    if (residenceUuid.isEmpty) return null;
    final env = await AppCacheStore.read(GuardCacheKeys.unitCallDirectory(residenceUuid));
    if (env == null) return null;

    final floorsRaw = env.data['floorsByBlock'];
    final floorsByBlock = <String, List<UnitFloorOption>>{};
    if (floorsRaw is Map) {
      for (final e in floorsRaw.entries) {
        final list = e.value;
        if (list is! List) continue;
        floorsByBlock[e.key.toString()] = list
            .whereType<Map>()
            .map(
              (m) => UnitFloorOption(
                name: m['name']?.toString() ?? '',
                block: m['block']?.toString() ?? e.key.toString(),
              ),
            )
            .toList();
      }
    }

    final unitsRaw = env.data['unitsByBlockFloor'];
    final unitsByBlockFloor = <String, List<CallUnitRow>>{};
    if (unitsRaw is Map) {
      for (final e in unitsRaw.entries) {
        final list = e.value;
        if (list is! List) continue;
        unitsByBlockFloor[e.key.toString()] = list
            .whereType<Map>()
            .map((m) => CallUnitRow.fromCacheJson(Map<String, dynamic>.from(m), residenceUuid: residenceUuid))
            .toList();
      }
    }

    final officeRaw = env.data['officeUnits'];
    final officeUnits = officeRaw is List
        ? officeRaw
            .whereType<Map>()
            .map((m) => CallUnitRow.fromCacheJson(Map<String, dynamic>.from(m), residenceUuid: residenceUuid))
            .toList()
        : <CallUnitRow>[];

    final blocksRaw = env.data['blocks'];
    final blocks = blocksRaw is List ? blocksRaw.map((e) => e.toString()).toList() : <String>[];

    return UnitCallDirectoryCache(
      savedAt: env.savedAt,
      officeMode: env.data['officeMode'] == true,
      blocks: blocks,
      floorsByBlock: floorsByBlock,
      unitsByBlockFloor: unitsByBlockFloor,
      officeUnits: officeUnits,
    );
  }
}
