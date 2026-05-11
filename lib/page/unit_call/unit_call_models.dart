/// Domain rows for Android `UnitActivity` / `UnitAdapter` (call flow).
class UnitMemberLine {
  const UnitMemberLine({
    required this.membershipUuid,
    required this.name,
    required this.phone,
    required this.membershipType,
  });

  final String membershipUuid;
  final String name;
  final String phone;
  final String membershipType;
}

class CallUnitRow {
  const CallUnitRow({
    required this.id,
    required this.name,
    required this.residenceUuid,
    required this.ownerUuid,
    required this.ownerName,
    required this.block,
    required this.floor,
    required this.members,
    this.expanded = false,
  });

  final String id;
  final String name;
  final String residenceUuid;
  final String ownerUuid;
  final String ownerName;
  final String block;
  final String floor;
  final List<UnitMemberLine> members;
  final bool expanded;

  CallUnitRow copyWith({bool? expanded}) => CallUnitRow(
    id: id,
    name: name,
    residenceUuid: residenceUuid,
    ownerUuid: ownerUuid,
    ownerName: ownerName,
    block: block,
    floor: floor,
    members: members,
    expanded: expanded ?? this.expanded,
  );
}

class UnitFloorOption {
  const UnitFloorOption({required this.name, required this.block});

  final String name;
  final String block;
}
