import 'call_recent_models.dart';

/// Parses `GET data/call_history` `resource` items (Android `VoipCallHistoryActivity`).
List<CallHistoryRow> parseCallHistoryResources(List<dynamic> resource) {
  final out = <CallHistoryRow>[];
  for (final raw in resource) {
    if (raw is! Map) continue;
    final m = Map<String, dynamic>.from(raw);
    final row = _parseOne(m);
    if (row != null) out.add(row);
  }
  // Android inserts at index 0 in loop order → newest-first vs API `call_at ASC`.
  out.sort((a, b) => b.callAtRaw.compareTo(a.callAtRaw));
  return out;
}

CallHistoryRow? _parseOne(Map<String, dynamic> m) {
  final uuid = m['uuid']?.toString();
  if (uuid == null || uuid.isEmpty) return null;

  final unitRaw = m['residence_units_by_unit_uuid'];
  final profileRaw = m['user_profiles_by_receiver_profile_uuid'];
  if (unitRaw is! Map || profileRaw is! Map) return null;

  final unit = Map<String, dynamic>.from(unitRaw);
  final profile = Map<String, dynamic>.from(profileRaw);

  final unitId = unit['uuid']?.toString() ?? '';
  final unitName = unit['name']?.toString() ?? '';
  final residenceUuid = unit['residence_uuid']?.toString() ?? '';
  final ownerUuid = unit['owner_uuid']?.toString() ?? '';

  final receiverUuid = profile['uuid']?.toString() ?? '';
  final receiverName = profile['name']?.toString() ?? '';
  final profilePhone = profile['phone']?.toString() ??
      profile['contact_number']?.toString() ??
      profile['mobile']?.toString() ??
      '';

  final receiverTypeLabel = ownerUuid.isNotEmpty && ownerUuid == receiverUuid ? 'Owner' : 'Member';

  final callAt = m['call_at']?.toString() ?? '';
  final callStatus = m['call_status']?.toString() ?? '';
  final receiverProfileUuid = m['receiver_profile_uuid']?.toString() ?? receiverUuid;

  if (unitId.isEmpty || callAt.isEmpty) return null;

  return CallHistoryRow(
    uuid: uuid,
    residenceUuid: residenceUuid,
    receiverName: receiverName.isEmpty ? '—' : receiverName,
    receiverTypeLabel: receiverTypeLabel,
    unitId: unitId,
    unitName: unitName.isEmpty ? '—' : unitName,
    receiverProfileUuid: receiverProfileUuid,
    callAtRaw: callAt,
    callStatus: callStatus,
    receiverPhone: profilePhone.trim(),
  );
}
