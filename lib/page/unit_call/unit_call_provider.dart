import 'dart:async';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_logger.dart';
import '../../core/dashboard_prefs.dart';
import '../../core/unit_call_session_prefs.dart';
import 'unit_call_parser.dart';
import 'unit_call_repository.dart';
import 'unit_call_session_restore.dart';
import 'unit_call_state.dart';
import 'unit_call_strings.dart';

final unitCallProvider = NotifierProvider<UnitCallNotifier, UnitCallState>(UnitCallNotifier.new);

class UnitCallNotifier extends Notifier<UnitCallState> {
  @override
  UnitCallState build() => const UnitCallState();

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

    final repo = ref.read(unitCallRepositoryProvider);
    final cached = await repo.loadCachedResources(snap.residenceId);
    if (cached.isNotEmpty) {
      await _applyResourcesAndMergeSession(cached, loading: false);
    }

    await refreshFromNetwork();
  }

  Future<void> refreshFromNetwork() async {
    final id = state.residenceUuid;
    if (id.isEmpty) return;
    state = state.copyWith(refreshing: true, clearError: true);
    try {
      final repo = ref.read(unitCallRepositoryProvider);
      final raw = await repo.fetchAllResidenceUnits(id);
      await _applyResourcesAndMergeSession(raw, loading: false);
      state = state.copyWith(refreshing: false, loading: false);
    } on DioException catch (e, st) {
      AppLog.error('Unit list failed', tag: 'UnitCall', error: e, stackTrace: st);
      state = state.copyWith(
        refreshing: false,
        loading: false,
        error: e.message ?? 'Network error',
      );
    } catch (e, st) {
      AppLog.error('Unit list failed', tag: 'UnitCall', error: e, stackTrace: st);
      state = state.copyWith(refreshing: false, loading: false, error: 'Something went wrong');
    }
  }

  Future<void> _applyResourcesAndMergeSession(
    List<Map<String, dynamic>> raw, {
    required bool loading,
  }) async {
    final rows = parseResidenceUnitResources(raw);
    final blocks = distinctBlockLabels(rows);
    final office = state.officeMode;
    state = state.copyWith(
      loading: loading,
      units: rows,
      blocks: blocks,
      floors: const [],
      clearSelectedBlock: true,
      clearSelectedFloor: true,
      step: office ? UnitCallStep.units : UnitCallStep.blocks,
      expandedUnitIds: {},
      searchQuery: '',
    );
    state = await mergeStoredUnitCallSession(state);
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

  void selectBlock(String blockLabel) {
    final floors = floorsForBlock(state.units, blockLabel);
    state = state.copyWith(
      step: UnitCallStep.floors,
      selectedBlock: blockLabel,
      floors: floors,
      clearSelectedFloor: true,
    );
    _persistSession();
  }

  void selectFloor(String floorName) {
    state = state.copyWith(step: UnitCallStep.units, selectedFloor: floorName, searchQuery: '');
    _persistSession();
  }

  void handleBack() {
    if (state.officeMode) return;
    switch (state.step) {
      case UnitCallStep.units:
        state = state.copyWith(
          step: UnitCallStep.floors,
          searchQuery: '',
          expandedUnitIds: {},
          clearSelectedFloor: true,
        );
      case UnitCallStep.floors:
        state = state.copyWith(
          step: UnitCallStep.blocks,
          floors: const [],
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

  void toggleUnitExpanded(String unitId) {
    final next = Set<String>.from(state.expandedUnitIds);
    if (next.contains(unitId)) {
      next.remove(unitId);
    } else {
      next.add(unitId);
    }
    state = state.copyWith(expandedUnitIds: next);
    _persistSession();
  }
}
