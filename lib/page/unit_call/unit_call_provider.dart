import 'dart:async';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api_error_message.dart';
import '../../core/app_logger.dart';
import '../../core/dashboard_prefs.dart';
import '../../core/unit_call_session_prefs.dart';
import '../../core/api/contracts/guard_unit_call_repository.dart';
import 'guard_unit_call_repository.dart';
import 'unit_call_models.dart';
import 'unit_call_session_restore.dart';
import 'unit_call_state.dart';
import 'unit_call_strings.dart';

final unitCallProvider = NotifierProvider<UnitCallNotifier, UnitCallState>(UnitCallNotifier.new);

class UnitCallNotifier extends Notifier<UnitCallState> {
  @override
  UnitCallState build() => const UnitCallState();

  final Map<String, List<UnitFloorOption>> _floorsByBlock = {};
  final Map<String, List<CallUnitRow>> _unitsByBlockFloor = {};

  GuardUnitCallRepository get _repo => ref.read(guardUnitCallRepositoryProvider);

  static String _blockFloorKey(String block, String floor) =>
      '${block.toUpperCase()}|${floor.toUpperCase()}';

  Future<void> bootstrap() async {
    state = const UnitCallState();
    final snap = await DashboardPrefs.loadSnapshot();
    final office = snap.officeEnvironment;
    if (snap.residenceId.isEmpty) {
      state = state.copyWith(
        loading: false,
        error: UnitCallStrings.noResidence,
        officeMode: office,
        residenceName: snap.residenceName,
      );
      return;
    }

    state = state.copyWith(
      officeMode: office,
      residenceName: snap.residenceName,
      residenceUuid: snap.residenceId,
      callOption: snap.callOption,
      step: office ? UnitCallStep.units : UnitCallStep.blocks,
      clearError: true,
    );

    final session = await readUnitCallSessionRestore(snap.residenceId);
    if (office) {
      await _loadOfficeUnits(session);
    } else {
      await _loadBlocks(session);
    }
  }

  Future<void> refreshFromNetwork() async {
    final session = await readUnitCallSessionRestore(state.residenceUuid);
    if (state.officeMode) {
      await _loadOfficeUnits(session, refreshing: true);
    } else {
      await _loadBlocks(session, refreshing: true);
    }
  }

  Future<void> _prefetchHostsForUnits(String residenceId, List<CallUnitRow> rows) async {
    if (rows.isEmpty) return;
    final byId = <String, CallUnitRow>{for (final u in rows) u.id: u};
    await Future.wait(
      byId.keys.map((id) async {
        try {
          final members = await _repo.fetchHosts(residenceId, unitUuid: id);
          final r = byId[id]!;
          byId[id] = r.copyWith(
            members: members,
            hostsLoaded: true,
            ownerName: members.isNotEmpty ? members.first.name : '—',
          );
        } catch (e, st) {
          AppLog.error('Unit hosts failed', tag: 'UnitCall', error: e, stackTrace: st);
          final r = byId[id]!;
          byId[id] = r.copyWith(members: const [], hostsLoaded: true);
        }
      }),
    );
    for (var i = 0; i < rows.length; i++) {
      rows[i] = byId[rows[i].id] ?? rows[i];
    }
  }

  /// Loads floors → units → hosts for every block (parallel where safe).
  Future<void> _prefetchDirectoryData(String residenceId, List<String> blockLabels) async {
    _floorsByBlock.clear();
    _unitsByBlockFloor.clear();

    await Future.wait(
      blockLabels.map((b) async {
        try {
          _floorsByBlock[b] = await _repo.fetchFloors(residenceId, block: b);
        } catch (e, st) {
          AppLog.error('Unit floors failed', tag: 'UnitCall', error: e, stackTrace: st);
          _floorsByBlock[b] = [];
        }
      }),
    );

    final unitPairs = <({String block, String floor})>[];
    for (final block in blockLabels) {
      for (final f in _floorsByBlock[block] ?? const <UnitFloorOption>[]) {
        unitPairs.add((block: block, floor: f.name));
      }
    }

    await Future.wait(
      unitPairs.map((p) async {
        final key = _blockFloorKey(p.block, p.floor);
        try {
          final units = await _repo.fetchUnits(residenceId, block: p.block, floor: p.floor);
          _unitsByBlockFloor[key] = units;
        } catch (e, st) {
          AppLog.error('Unit list failed', tag: 'UnitCall', error: e, stackTrace: st);
          _unitsByBlockFloor[key] = [];
        }
      }),
    );

    final allRows = <CallUnitRow>[];
    for (final list in _unitsByBlockFloor.values) {
      allRows.addAll(list);
    }
    final unique = <String, CallUnitRow>{};
    for (final u in allRows) {
      unique[u.id] = u;
    }
    final merged = unique.values.toList();
    await _prefetchHostsForUnits(residenceId, merged);
    final byId = {for (final u in merged) u.id: u};
    for (final key in _unitsByBlockFloor.keys.toList()) {
      _unitsByBlockFloor[key] = _unitsByBlockFloor[key]!
          .map((u) => byId[u.id] ?? u)
          .toList();
    }
  }

  Future<void> _loadBlocks(UnitCallSessionRestore? session, {bool refreshing = false}) async {
    final id = state.residenceUuid;
    if (id.isEmpty) return;
    state = state.copyWith(
      loading: !refreshing,
      refreshing: refreshing,
      stepLoading: true,
      clearError: true,
    );
    try {
      final items = await _repo.fetchBlocks(id);
      final labels = items.map((e) => e.label).toList();
      await _prefetchDirectoryData(id, labels);
      state = state.copyWith(
        loading: false,
        refreshing: false,
        stepLoading: false,
        blocks: labels,
        step: UnitCallStep.blocks,
        floors: const [],
        units: const [],
        clearSelectedBlock: true,
        clearSelectedFloor: true,
        expandedUnitIds: {},
        searchQuery: '',
      );
      await _continueSession(session);
    } on DioException catch (e, st) {
      AppLog.error('Unit blocks failed', tag: 'UnitCall', error: e, stackTrace: st);
      state = state.copyWith(
        loading: false,
        refreshing: false,
        stepLoading: false,
        error: apiErrorMessage(e),
      );
    } catch (e, st) {
      AppLog.error('Unit blocks failed', tag: 'UnitCall', error: e, stackTrace: st);
      state = state.copyWith(
        loading: false,
        refreshing: false,
        stepLoading: false,
        error: 'Something went wrong',
      );
    }
  }

  Future<void> _loadOfficeUnits(UnitCallSessionRestore? session, {bool refreshing = false}) async {
    final id = state.residenceUuid;
    if (id.isEmpty) return;
    state = state.copyWith(
      loading: !refreshing,
      refreshing: refreshing,
      stepLoading: true,
      clearError: true,
    );
    try {
      final units = List<CallUnitRow>.from(await _repo.fetchUnits(id));
      await _prefetchHostsForUnits(id, units);
      state = state.copyWith(
        loading: false,
        refreshing: false,
        stepLoading: false,
        step: UnitCallStep.units,
        units: units,
        searchQuery: session?.searchQuery ?? '',
        expandedUnitIds: session?.expandedIds ?? {},
      );
      _persistSession();
    } on DioException catch (e, st) {
      AppLog.error('Unit list failed', tag: 'UnitCall', error: e, stackTrace: st);
      state = state.copyWith(
        loading: false,
        refreshing: false,
        stepLoading: false,
        error: apiErrorMessage(e),
      );
    } catch (e, st) {
      AppLog.error('Unit list failed', tag: 'UnitCall', error: e, stackTrace: st);
      state = state.copyWith(
        loading: false,
        refreshing: false,
        stepLoading: false,
        error: 'Something went wrong',
      );
    }
  }

  Future<void> _continueSession(UnitCallSessionRestore? session) async {
    if (session == null || session.officeMode) return;
    final block = _matchBlock(session.selectedBlock);
    if (block == null) return;
    if (session.step == UnitCallStep.blocks) return;

    _applyFloorsForBlock(block);
    if (session.step == UnitCallStep.floors) return;

    final floor = _matchFloor(session.selectedFloor);
    if (floor == null) return;

    _applyUnitsForBlockFloor(
      block,
      floor,
      searchQuery: session.searchQuery,
      expandedIds: session.expandedIds,
    );
  }

  String? _matchBlock(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final b in state.blocks) {
      if (b.toUpperCase() == raw.toUpperCase()) return b;
    }
    return null;
  }

  String? _matchFloor(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final f in state.floors) {
      if (f.name.toUpperCase() == raw.toUpperCase()) return f.name;
    }
    return null;
  }

  void selectBlock(String blockLabel) {
    _applyFloorsForBlock(blockLabel);
  }

  void _applyFloorsForBlock(String blockLabel) {
    state = state.copyWith(
      stepLoading: false,
      step: UnitCallStep.floors,
      selectedBlock: blockLabel,
      floors: List<UnitFloorOption>.from(_floorsByBlock[blockLabel] ?? const []),
      units: const [],
      clearSelectedFloor: true,
      expandedUnitIds: {},
      searchQuery: '',
      clearError: true,
    );
    _persistSession();
  }

  void selectFloor(String floorName) {
    final block = state.selectedBlock;
    if (block == null) return;
    _applyUnitsForBlockFloor(block, floorName);
  }

  void _applyUnitsForBlockFloor(
    String block,
    String floor, {
    String searchQuery = '',
    Set<String> expandedIds = const {},
  }) {
    final key = _blockFloorKey(block, floor);
    final cached = _unitsByBlockFloor[key] ?? const <CallUnitRow>[];
    state = state.copyWith(
      stepLoading: false,
      step: UnitCallStep.units,
      selectedBlock: block,
      selectedFloor: floor,
      floors: List<UnitFloorOption>.from(_floorsByBlock[block] ?? const []),
      units: List<CallUnitRow>.from(cached),
      searchQuery: searchQuery,
      expandedUnitIds: Set<String>.from(expandedIds),
      clearError: true,
    );
    _persistSession();
  }

  void _persistSession() {
    final s = state;
    if (s.residenceUuid.isEmpty) return;
    unawaited(
      UnitCallSessionPrefs.write(<String, dynamic>{
        'residenceUuid': s.residenceUuid,
        'officeMode': s.officeMode,
        'step': s.step.index,
        'selectedBlock': s.selectedBlock,
        'selectedFloor': s.selectedFloor,
        'searchQuery': s.searchQuery,
        'expandedIds': s.expandedUnitIds.toList(),
      }),
    );
  }

  void handleBack() {
    if (state.officeMode) return;
    switch (state.step) {
      case UnitCallStep.units:
        state = state.copyWith(
          step: UnitCallStep.floors,
          searchQuery: '',
          units: const [],
          expandedUnitIds: {},
          hostsLoadingUnitIds: {},
          clearSelectedFloor: true,
        );
      case UnitCallStep.floors:
        state = state.copyWith(
          step: UnitCallStep.blocks,
          floors: const [],
          searchQuery: '',
          clearSelectedBlock: true,
          clearSelectedFloor: true,
        );
      case UnitCallStep.blocks:
        break;
    }
    _persistSession();
  }

  void setSearch(String q) {
    state = state.copyWith(searchQuery: q);
    _persistSession();
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<void> toggleUnitExpanded(String unitId) async {
    final next = Set<String>.from(state.expandedUnitIds);
    final expanding = !next.contains(unitId);
    if (expanding) {
      next.add(unitId);
    } else {
      next.remove(unitId);
    }
    state = state.copyWith(expandedUnitIds: next);
    _persistSession();
    if (expanding) await _loadHosts(unitId);
  }

  Future<void> _loadHosts(String unitId) async {
    final index = state.units.indexWhere((u) => u.id == unitId);
    if (index < 0) return;
    if (state.units[index].hostsLoaded) return;

    final loading = Set<String>.from(state.hostsLoadingUnitIds)..add(unitId);
    state = state.copyWith(hostsLoadingUnitIds: loading);
    try {
      final members = await _repo.fetchHosts(
        state.residenceUuid,
        unitUuid: unitId,
      );
      final updated = state.units.map((u) {
        if (u.id != unitId) return u;
        final owner = members.isNotEmpty ? members.first.name : '—';
        return u.copyWith(members: members, hostsLoaded: true, ownerName: owner);
      }).toList();
      final done = Set<String>.from(state.hostsLoadingUnitIds)..remove(unitId);
      var expanded = Set<String>.from(state.expandedUnitIds);
      if (members.isEmpty) {
        expanded.remove(unitId);
      }
      state = state.copyWith(units: updated, hostsLoadingUnitIds: done, expandedUnitIds: expanded);
      _syncCachedUnitRow(unitId, updated.firstWhere((u) => u.id == unitId));
      _persistSession();
    } on DioException catch (e, st) {
      AppLog.error('Unit hosts failed', tag: 'UnitCall', error: e, stackTrace: st);
      final done = Set<String>.from(state.hostsLoadingUnitIds)..remove(unitId);
      state = state.copyWith(hostsLoadingUnitIds: done, error: apiErrorMessage(e));
    } catch (e, st) {
      AppLog.error('Unit hosts failed', tag: 'UnitCall', error: e, stackTrace: st);
      final done = Set<String>.from(state.hostsLoadingUnitIds)..remove(unitId);
      state = state.copyWith(hostsLoadingUnitIds: done, error: 'Something went wrong');
    }
  }

  void _syncCachedUnitRow(String unitId, CallUnitRow row) {
    final b = state.selectedBlock;
    final f = state.selectedFloor;
    if (b == null || f == null) return;
    final key = _blockFloorKey(b, f);
    final list = _unitsByBlockFloor[key];
    if (list == null) return;
    _unitsByBlockFloor[key] = list.map((u) => u.id == unitId ? row : u).toList();
  }
}
