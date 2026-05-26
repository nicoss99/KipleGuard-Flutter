/// Guard API `{ label, value }` (blocks / floors).
class UnitLabelValue {
  const UnitLabelValue({required this.label, required this.value});

  final String label;
  final String value;

  factory UnitLabelValue.fromJson(Map<String, dynamic> json) => UnitLabelValue(
        label: json['label']?.toString() ?? json['value']?.toString() ?? '',
        value: json['value']?.toString() ?? json['label']?.toString() ?? '',
      );
}

/// Domain rows for Android `UnitActivity` / `UnitAdapter` (call flow).
class UnitMemberLine {
  const UnitMemberLine({
    required this.membershipUuid,
    required this.name,
    required this.phone,
    required this.membershipType,
    this.userId,
  });

  final String membershipUuid;
  final String name;
  final String phone;
  final String membershipType;
  /// Guard host user id (`guest_of_user_id` on visitor register).
  final int? userId;

  factory UnitMemberLine.fromGuardHostJson(Map<String, dynamic> json) {
    final userId = _intOrNull(json['user_id']) ?? _intOrNull(json['id']);
    return UnitMemberLine(
      membershipUuid: json['uuid']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      membershipType: json['membership_role']?.toString() ?? '',
      userId: userId,
    );
  }

  factory UnitMemberLine.fromCacheJson(Map<String, dynamic> json) => UnitMemberLine(
        membershipUuid: json['membershipUuid']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        membershipType: json['membershipType']?.toString() ?? '',
        userId: _intOrNull(json['userId']),
      );

  Map<String, dynamic> toCacheJson() => {
        'membershipUuid': membershipUuid,
        'name': name,
        'phone': phone,
        'membershipType': membershipType,
        if (userId != null) 'userId': userId,
      };
}

int? _intOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
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
    this.hostsLoaded = false,
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
  final bool hostsLoaded;

  CallUnitRow copyWith({
    bool? expanded,
    List<UnitMemberLine>? members,
    bool? hostsLoaded,
    String? ownerName,
  }) =>
      CallUnitRow(
        id: id,
        name: name,
        residenceUuid: residenceUuid,
        ownerUuid: ownerUuid,
        ownerName: ownerName ?? this.ownerName,
        block: block,
        floor: floor,
        members: members ?? this.members,
        expanded: expanded ?? this.expanded,
        hostsLoaded: hostsLoaded ?? this.hostsLoaded,
      );

  factory CallUnitRow.fromCacheJson(
    Map<String, dynamic> json, {
    required String residenceUuid,
  }) {
    final membersRaw = json['members'];
    final members = membersRaw is List
        ? membersRaw
            .whereType<Map>()
            .map((e) => UnitMemberLine.fromCacheJson(Map<String, dynamic>.from(e)))
            .toList()
        : <UnitMemberLine>[];
    return CallUnitRow(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      residenceUuid: residenceUuid,
      ownerUuid: json['ownerUuid']?.toString() ?? '',
      ownerName: json['ownerName']?.toString() ?? '—',
      block: json['block']?.toString() ?? '',
      floor: json['floor']?.toString() ?? '',
      members: members,
      hostsLoaded: json['hostsLoaded'] == true,
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'name': name,
        'ownerUuid': ownerUuid,
        'ownerName': ownerName,
        'block': block,
        'floor': floor,
        'hostsLoaded': hostsLoaded,
        'members': members.map((m) => m.toCacheJson()).toList(),
      };

  factory CallUnitRow.fromGuardUnitJson(
    Map<String, dynamic> json, {
    required String residenceUuid,
  }) {
    final uuid = json['uuid']?.toString() ?? '';
    final label = json['display_label']?.toString() ??
        json['unit_number']?.toString() ??
        uuid;
    return CallUnitRow(
      id: uuid,
      name: label,
      residenceUuid: residenceUuid,
      ownerUuid: '',
      ownerName: '—',
      block: json['block']?.toString() ?? '',
      floor: json['floor']?.toString() ?? '',
      members: const [],
      hostsLoaded: false,
    );
  }
}

class UnitFloorOption {
  const UnitFloorOption({required this.name, required this.block});

  final String name;
  final String block;

  factory UnitFloorOption.fromGuardJson(Map<String, dynamic> json, String block) =>
      UnitFloorOption(
        name: json['label']?.toString() ?? json['value']?.toString() ?? '',
        block: json['block']?.toString() ?? block,
      );
}
