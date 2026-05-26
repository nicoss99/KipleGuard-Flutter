import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/guard_api_message.dart';
import '../../core/guard_api_paths.dart';
import '../../service/api_service.dart';
import 'unit_call_models.dart';

final guardUnitCallRepositoryProvider = Provider<GuardUnitCallRepository>(
  (ref) => GuardUnitCallRepository(ref.watch(dioProvider)),
);

class GuardUnitCallRepository {
  GuardUnitCallRepository(this._dio);

  final Dio _dio;

  Future<List<UnitLabelValue>> fetchBlocks(String residenceUuid) async {
    final data = await _getData(GuardApiPaths.unitBlocks(residenceUuid));
    final raw = data?['blocks'];
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(UnitLabelValue.fromJson)
        .where((e) => e.value.isNotEmpty)
        .toList();
  }

  Future<List<UnitFloorOption>> fetchFloors(
    String residenceUuid, {
    required String block,
  }) async {
    final data = await _getData(
      GuardApiPaths.unitFloors(residenceUuid),
      query: <String, dynamic>{'block': block},
    );
    final raw = data?['floors'];
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((m) => UnitFloorOption.fromGuardJson(m, block))
        .where((e) => e.name.isNotEmpty)
        .toList();
  }

  Future<List<CallUnitRow>> fetchUnits(
    String residenceUuid, {
    String? block,
    String? floor,
  }) async {
    final query = <String, dynamic>{};
    if (block != null && block.isNotEmpty) query['block'] = block;
    if (floor != null && floor.isNotEmpty) query['floor'] = floor;
    final data = await _getData(
      GuardApiPaths.unitList(residenceUuid),
      query: query.isEmpty ? null : query,
    );
    final raw = data?['units'];
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((m) => CallUnitRow.fromGuardUnitJson(m, residenceUuid: residenceUuid))
        .toList();
  }

  static String _blockFloorKey(String block, String floor) =>
      '${block.toUpperCase()}|${floor.toUpperCase()}';

  /// All units for a site — office: single list; residence: blocks → floors → units.
  Future<List<CallUnitRow>> fetchAllUnitsForResidence(
    String residenceUuid, {
    required bool officeMode,
  }) async {
    if (officeMode) {
      return fetchUnits(residenceUuid);
    }

    final blocks = await fetchBlocks(residenceUuid);
    final blockLabels = blocks.map((e) => e.label).where((l) => l.isNotEmpty).toList();
    if (blockLabels.isEmpty) return [];

    final floorsByBlock = <String, List<UnitFloorOption>>{};
    await Future.wait(
      blockLabels.map((b) async {
        try {
          floorsByBlock[b] = await fetchFloors(residenceUuid, block: b);
        } catch (_) {
          floorsByBlock[b] = [];
        }
      }),
    );

    final unitPairs = <({String block, String floor})>[];
    for (final block in blockLabels) {
      for (final f in floorsByBlock[block] ?? const <UnitFloorOption>[]) {
        unitPairs.add((block: block, floor: f.name));
      }
    }

    final unitsByBlockFloor = <String, List<CallUnitRow>>{};
    await Future.wait(
      unitPairs.map((p) async {
        final key = _blockFloorKey(p.block, p.floor);
        try {
          unitsByBlockFloor[key] = await fetchUnits(
            residenceUuid,
            block: p.block,
            floor: p.floor,
          );
        } catch (_) {
          unitsByBlockFloor[key] = [];
        }
      }),
    );

    final unique = <String, CallUnitRow>{};
    for (final list in unitsByBlockFloor.values) {
      for (final u in list) {
        unique[u.id] = u;
      }
    }
    return unique.values.toList();
  }

  Future<List<UnitMemberLine>> fetchHosts(
    String residenceUuid, {
    required String unitUuid,
  }) async {
    final data = await _getData(GuardApiPaths.unitHosts(residenceUuid, unitUuid));
    final raw = data?['hosts'];
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(UnitMemberLine.fromGuardHostJson)
        .where((e) => e.membershipUuid.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>?> _getData(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
    );
    final body = res.data;
    if (!guardApiSuccess(body)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: body?['message'] as String? ?? 'Request failed',
      );
    }
    return guardApiData(body);
  }
}
