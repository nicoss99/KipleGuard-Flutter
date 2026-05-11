import 'unit_call_models.dart';
import 'unit_call_strings.dart';

enum UnitCallStep { blocks, floors, units }

class UnitCallState {
  const UnitCallState({
    this.loading = true,
    this.refreshing = false,
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
  });

  final bool loading;
  final bool refreshing;
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

  String get appBarTitle {
    if (officeMode) return UnitCallStrings.selectHost;
    return switch (step) {
      UnitCallStep.blocks => UnitCallStrings.selectBlock,
      UnitCallStep.floors => UnitCallStrings.selectFloor,
      UnitCallStep.units => UnitCallStrings.pageTitleCall,
    };
  }

  List<CallUnitRow> get visibleUnits {
    final q = searchQuery.trim().toUpperCase().replaceAll('-', '');
    bool nameMatch(CallUnitRow u) =>
        q.isEmpty || u.name.toUpperCase().replaceAll('-', '').contains(q);

    if (officeMode) {
      return units.where(nameMatch).toList();
    }
    if (step != UnitCallStep.units) return [];
    final b = selectedBlock;
    final f = selectedFloor;
    if (b == null || f == null) return [];
    final bu = b.toUpperCase();
    final fu = f.toUpperCase();
    return units.where((u) {
      if (u.block.toUpperCase() != bu) return false;
      if (u.floor.toUpperCase() != fu) return false;
      return nameMatch(u);
    }).toList();
  }

  UnitCallState copyWith({
    bool? loading,
    bool? refreshing,
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
  }) {
    return UnitCallState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
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
    );
  }
}
