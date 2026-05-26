import 'unit_call_models.dart';
import 'unit_call_strings.dart';

enum UnitCallStep { blocks, floors, units }

String _unitCallSearchNorm(String s) =>
    s.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
class UnitCallState {
  const UnitCallState({
    this.loading = true,
    this.refreshing = false,
    this.stepLoading = false,
    this.error,
    this.step = UnitCallStep.blocks,
    this.officeMode = false,
    this.residenceName = '',
    this.residenceUuid = '',
    this.callOption = '',
    this.blocks = const [],
    this.selectedBlock,
    this.floors = const [],
    this.selectedFloor,
    this.units = const [],
    this.searchQuery = '',
    this.expandedUnitIds = const {},
    this.hostsLoadingUnitIds = const {},
  });

  final bool loading;
  final bool refreshing;
  final bool stepLoading;
  final String? error;
  final UnitCallStep step;
  final bool officeMode;
  final String residenceName;
  final String residenceUuid;
  final String callOption;
  final List<String> blocks;
  final String? selectedBlock;
  final List<UnitFloorOption> floors;
  final String? selectedFloor;
  final List<CallUnitRow> units;
  final String searchQuery;
  final Set<String> expandedUnitIds;
  final Set<String> hostsLoadingUnitIds;

  String get appBarTitle {
    if (officeMode) return UnitCallStrings.selectHost;
    return switch (step) {
      UnitCallStep.blocks => UnitCallStrings.selectBlock,
      UnitCallStep.floors => UnitCallStrings.selectFloor,
      UnitCallStep.units => UnitCallStrings.pageTitleCall,
    };
  }

  List<CallUnitRow> get visibleUnits {
    final q = _unitCallSearchNorm(searchQuery);
    bool match(CallUnitRow u) {
      if (q.isEmpty) return true;
      return _unitCallSearchNorm(u.name).contains(q) ||
          _unitCallSearchNorm(u.block).contains(q) ||
          _unitCallSearchNorm(u.floor).contains(q) ||
          _unitCallSearchNorm(u.ownerName).contains(q);
    }
    if (step != UnitCallStep.units && !officeMode) return [];
    return units.where(match).toList();
  }

  List<String> get visibleBlocks {
    if (officeMode || step != UnitCallStep.blocks) return blocks;
    final q = _unitCallSearchNorm(searchQuery);
    if (q.isEmpty) return blocks;
    return blocks.where((b) => _unitCallSearchNorm(b).contains(q)).toList();
  }

  List<UnitFloorOption> get visibleFloors {
    if (officeMode || step != UnitCallStep.floors) return floors;
    final q = _unitCallSearchNorm(searchQuery);
    if (q.isEmpty) return floors;
    return floors.where((f) => _unitCallSearchNorm(f.name).contains(q)).toList();
  }
  UnitCallState copyWith({
    bool? loading,
    bool? refreshing,
    bool? stepLoading,
    String? error,
    bool clearError = false,
    UnitCallStep? step,
    bool? officeMode,
    String? residenceName,
    String? residenceUuid,
    String? callOption,
    List<String>? blocks,
    String? selectedBlock,
    bool clearSelectedBlock = false,
    List<UnitFloorOption>? floors,
    String? selectedFloor,
    bool clearSelectedFloor = false,
    List<CallUnitRow>? units,
    String? searchQuery,
    Set<String>? expandedUnitIds,
    Set<String>? hostsLoadingUnitIds,
  }) {
    return UnitCallState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      stepLoading: stepLoading ?? this.stepLoading,
      error: clearError ? null : (error ?? this.error),
      step: step ?? this.step,
      officeMode: officeMode ?? this.officeMode,
      residenceName: residenceName ?? this.residenceName,
      residenceUuid: residenceUuid ?? this.residenceUuid,
      callOption: callOption ?? this.callOption,
      blocks: blocks ?? this.blocks,
      selectedBlock: clearSelectedBlock ? null : (selectedBlock ?? this.selectedBlock),
      floors: floors ?? this.floors,
      selectedFloor: clearSelectedFloor ? null : (selectedFloor ?? this.selectedFloor),
      units: units ?? this.units,
      searchQuery: searchQuery ?? this.searchQuery,
      expandedUnitIds: expandedUnitIds ?? this.expandedUnitIds,
      hostsLoadingUnitIds: hostsLoadingUnitIds ?? this.hostsLoadingUnitIds,
    );
  }
}
