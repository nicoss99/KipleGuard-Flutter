import '../../../page/unit_call/unit_call_models.dart';

/// Guard unit directory API (blocks, floors, units, hosts).
abstract interface class GuardUnitCallRepository {
  Future<List<UnitLabelValue>> fetchBlocks(String residenceUuid);

  Future<List<UnitFloorOption>> fetchFloors(
    String residenceUuid, {
    required String block,
  });

  Future<List<CallUnitRow>> fetchUnits(
    String residenceUuid, {
    String? block,
    String? floor,
  });

  Future<List<CallUnitRow>> fetchAllUnitsForResidence(
    String residenceUuid, {
    required bool officeMode,
  });

  Future<List<UnitMemberLine>> fetchHosts(
    String residenceUuid, {
    required String unitUuid,
  });
}
