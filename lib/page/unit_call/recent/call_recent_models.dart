/// Android `VoipCallHistoryObject` / `VoipCallHistoryActivity` row.
class CallHistoryRow {
  const CallHistoryRow({
    required this.uuid,
    required this.residenceUuid,
    required this.receiverName,
    required this.receiverTypeLabel,
    required this.unitId,
    required this.unitName,
    required this.receiverProfileUuid,
    required this.callAtRaw,
    required this.callStatus,
  });

  final String uuid;
  final String residenceUuid;
  final String receiverName;
  final String receiverTypeLabel;
  final String unitId;
  final String unitName;
  final String receiverProfileUuid;
  final String callAtRaw;
  final String callStatus;
}
