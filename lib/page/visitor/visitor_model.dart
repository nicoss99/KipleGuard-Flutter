/// List bucket from Android `visitorList(..., status)` — drives stripe on Visitor(s) tab.
enum VisitorListCategory { checkedIn, upcoming, overtime }

/// Row model for visitor list (Android `VisitorObject` subset).
class VisitorListItem {
  const VisitorListItem({
    required this.uuid,
    required this.name,
    required this.unitLabel,
    required this.carPlate,
    required this.passId,
    required this.visitStatus,
    required this.latestScanType,
    required this.startTime,
    required this.qrCode,
    required this.residenceUuid,
    required this.category,
    this.createdByUuid = '',
  });

  final String uuid;
  final String name;
  final String unitLabel;
  final String carPlate;
  final String passId;
  final String visitStatus;
  final String latestScanType;
  final String startTime;
  final String qrCode;
  final String residenceUuid;

  /// Android `VisitorAdapter` passes `data.created_by` into `scanQRcode` as `userProfileID`.
  final String createdByUuid;

  final VisitorListCategory category;
}
