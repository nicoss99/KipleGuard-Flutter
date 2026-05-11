import 'dart:convert';

import 'unit_call_models.dart';

/// Builds [CallUnitRow] list from `GET data/residence_units` `resource` items (Android `addUnit`).
List<CallUnitRow> parseResidenceUnitResources(List<Map<String, dynamic>> resources) {
  final out = <CallUnitRow>[];
  for (final resourceDetail in resources) {
    try {
      final row = _parseOne(resourceDetail);
      if (row != null) out.add(row);
    } catch (_) {}
  }
  return out;
}

CallUnitRow? _parseOne(Map<String, dynamic> resourceDetail) {
  final uuid = resourceDetail['uuid']?.toString();
  final name = resourceDetail['name']?.toString();
  final residenceUuid = resourceDetail['residence_uuid']?.toString();
  if (uuid == null || name == null || residenceUuid == null) return null;

  var ownerUuid = resourceDetail['owner_uuid']?.toString() ?? '';
  var ownerName = resourceDetail['owner_name']?.toString() ?? '';
  var block = resourceDetail['block']?.toString() ?? '';
  var floor = resourceDetail['floor']?.toString() ?? '';
  if (block.isEmpty || block == 'null') block = 'N/A Block';
  if (floor.isEmpty || floor == 'null') floor = 'N/A Floor';

  final members = <UnitMemberLine>[];
  final rawMem = resourceDetail['residence_unit_memberships_by_unit_uuid'];
  final list = _asJsonList(rawMem);
  for (final m in list) {
    if (m is! Map) continue;
    final map = Map<String, dynamic>.from(m);
    final membershipType = map['membership_type']?.toString() ?? '';
    final profileRaw = map['user_profiles_by_user_profile_uuid'];
    final ownerMap = _asObjectMap(profileRaw);
    if (ownerMap == null) continue;
    final membershipUuid = ownerMap['uuid']?.toString() ?? '';
    final membershipName = ownerMap['name']?.toString() ?? '';
    final membershipPhone = ownerMap['phone']?.toString() ?? '';
    if (membershipUuid.isEmpty) continue;

    members.add(
      UnitMemberLine(
        membershipUuid: membershipUuid,
        name: membershipName,
        phone: membershipPhone,
        membershipType: membershipType,
      ),
    );
  }
  members.sort((a, b) {
    final ap = a.membershipType.toLowerCase() == 'primary';
    final bp = b.membershipType.toLowerCase() == 'primary';
    if (ap && !bp) return -1;
    if (!ap && bp) return 1;
    return 0;
  });

  return CallUnitRow(
    id: uuid,
    name: name,
    residenceUuid: residenceUuid,
    ownerUuid: ownerUuid,
    ownerName: ownerName.isEmpty || ownerName.toLowerCase() == 'null' ? 'N/A' : ownerName,
    block: block,
    floor: floor,
    members: members,
    expanded: false,
  );
}

List<dynamic> _asJsonList(dynamic raw) {
  if (raw == null) return [];
  if (raw is List<dynamic>) return raw;
  if (raw is String) {
    try {
      final d = jsonDecode(raw);
      if (d is List<dynamic>) return d;
    } catch (_) {}
  }
  return [];
}

Map<String, dynamic>? _asObjectMap(dynamic raw) {
  if (raw == null) return null;
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  if (raw is String && raw.length > 6) {
    try {
      final d = jsonDecode(raw);
      if (d is Map<String, dynamic>) return d;
      if (d is Map) return Map<String, dynamic>.from(d);
    } catch (_) {}
  }
  return null;
}

/// Sorted unique blocks; label keeps first-seen casing (Android list).
List<String> distinctBlockLabels(List<CallUnitRow> units) {
  final map = <String, String>{};
  for (final u in units) {
    final k = u.block.toUpperCase();
    map.putIfAbsent(k, () => u.block);
  }
  final keys = map.keys.toList()..sort();
  return keys.map((k) => map[k]!).toList();
}

List<UnitFloorOption> floorsForBlock(List<CallUnitRow> units, String blockUpper) {
  String floorKey(String a, String b) => '${a.toUpperCase()}|${b.toUpperCase()}';
  final seen = <String>{};
  final out = <UnitFloorOption>[];
  for (final u in units) {
    if (u.block.toUpperCase() != blockUpper.toUpperCase()) continue;
    final k = floorKey(u.block, u.floor);
    if (seen.add(k)) {
      out.add(UnitFloorOption(name: u.floor, block: u.block));
    }
  }
  out.sort((a, b) => a.name.toUpperCase().compareTo(b.name.toUpperCase()));
  return out;
}
