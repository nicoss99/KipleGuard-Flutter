import '../register/register_ic_encrypt.dart';

/// Normalized visitor detail row (Android `VisitorDetailsActivity` subset).
class VisitorDetailFields {
  VisitorDetailFields({
    required this.uuid,
    required this.name,
    required this.phone,
    required this.carPlate,
    required this.passReference,
    required this.parkingLot,
    required this.temperature,
    required this.from,
    required this.qrCode,
    required this.residenceUuid,
    required this.residenceName,
    required this.userProfileUuid,
    required this.latestScanType,
    required this.visitStatus,
    required this.checkpointTimes,
    required this.repeatType,
    required this.unitName,
    required this.blockName,
    required this.hostName,
    required this.category,
    required this.remarks,
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    required this.actualArrivalTime,
    required this.actualExitTime,
    required this.icPassport,
    this.isLprEnabled = false,
  });

  factory VisitorDetailFields.fromResource(Map<String, dynamic> r) {
    final type = r['visitor_types_by_visitor_type_uuid'];
    var lpr = false;
    if (type is Map<String, dynamic>) {
      lpr = type['is_lpr_enabled'] == true;
    }
    /// Android checkout uses `user_profiles_by_user_profile_uuid.uuid` (`hostUUID`).
    var profileUuid = '';
    final hostProf = r['user_profiles_by_user_profile_uuid'];
    if (hostProf is Map<String, dynamic>) {
      profileUuid = hostProf['uuid']?.toString() ?? '';
    }
    if (profileUuid.isEmpty) {
      profileUuid = r['user_profile_uuid']?.toString() ?? '';
    }
    if (profileUuid.isEmpty) {
      final p = r['user_profile'];
      if (p is Map<String, dynamic>) {
        profileUuid = p['uuid']?.toString() ?? '';
      }
    }
    final cp = r['checkpoint_times'];
    final checkpointTimes = cp is int ? cp : int.tryParse(cp?.toString() ?? '0') ?? 0;

    var unitName = r['unit_name']?.toString() ?? '';
    var blockName = r['block_name']?.toString() ?? '';
    final ru = r['residence_units_by_unit_uuid'];
    if (ru is Map) {
      if (unitName.isEmpty) unitName = ru['name']?.toString() ?? '';
      if (blockName.isEmpty) {
        blockName = ru['block_name']?.toString() ?? ru['block']?.toString() ?? ru['floor']?.toString() ?? '';
      }
    }

    var hostName = r['host_name']?.toString() ?? '';
    final up = r['user_profiles_by_user_profile_uuid'];
    if (hostName.isEmpty && up is Map) {
      hostName = up['name']?.toString() ?? '';
    }

    return VisitorDetailFields(
      uuid: r['uuid']?.toString() ?? '',
      name: r['name']?.toString() ?? '',
      phone: r['phone_number']?.toString() ?? '',
      carPlate: r['car_plate_number']?.toString() ?? '',
      passReference: r['pass_reference_id']?.toString() ?? '',
      parkingLot: r['parking_lot']?.toString() ?? '',
      temperature: r['visitor_temp']?.toString() ?? '',
      from: r['visitor_from']?.toString() ?? '',
      qrCode: r['qr_code']?.toString() ?? '',
      residenceUuid: r['residence_uuid']?.toString() ?? '',
      residenceName: r['residence_name']?.toString() ?? '',
      userProfileUuid: profileUuid,
      latestScanType: r['latest_scan_type']?.toString() ?? '',
      visitStatus: r['visit_status']?.toString() ?? '',
      checkpointTimes: checkpointTimes,
      repeatType: r['repeat_type']?.toString() ?? 'ONE_TIME',
      unitName: unitName,
      blockName: blockName,
      hostName: hostName,
      category: r['category']?.toString() ?? '',
      remarks: r['remarks']?.toString() ?? '',
      createdAt: r['created_at']?.toString() ?? '',
      startTime: r['start_time']?.toString() ?? '',
      endTime: r['end_time']?.toString() ?? '',
      actualArrivalTime: r['actual_arrival_time']?.toString() ?? '',
      actualExitTime: r['actual_exit_time']?.toString() ?? '',
      icPassport: _icPassportPlainForDisplay(r),
      isLprEnabled: lpr,
    );
  }

  /// API stores `ic_passport` encrypted (same as register/patch). Decrypt for UI
  /// masking; keep raw if decrypt fails (legacy plaintext).
  static bool _hasIcPassportValue(dynamic raw) {
    if (raw == null) return false;
    final t = raw.toString().trim();
    if (t.isEmpty) return false;
    final lower = t.toLowerCase();
    return lower != 'null' && lower != 'undefined';
  }

  static String _icPassportPlainForDisplay(Map<String, dynamic> r) {
    if (!_hasIcPassportValue(r['ic_passport'])) return '';
    final cipher = r['ic_passport'].toString().trim();
    final resUuid = r['residence_uuid']?.toString() ?? '';
    if (resUuid.isEmpty) return cipher;
    final plain = decryptIcForResidence(cipher, resUuid).trim();
    if (plain.isNotEmpty) return plain;
    return _hasIcPassportValue(cipher) ? cipher : '';
  }

  final String uuid;
  final String name;
  final String phone;
  final String carPlate;
  final String passReference;
  final String parkingLot;
  final String temperature;
  final String from;
  final String qrCode;
  final String residenceUuid;
  final String residenceName;
  final String userProfileUuid;
  final String latestScanType;
  final String visitStatus;
  final bool isLprEnabled;
  final int checkpointTimes;
  final String repeatType;
  final String unitName;
  final String blockName;
  final String hostName;
  final String category;
  final String remarks;
  final String createdAt;
  final String startTime;
  final String endTime;
  final String actualArrivalTime;
  final String actualExitTime;
  final String icPassport;

  bool get hasQr => qrCode.trim().isNotEmpty;

  bool get checkedIn => latestScanType.toUpperCase() == 'IN';

  bool get _oneTimeDone =>
      repeatType.toLowerCase().contains('one') && checkpointTimes >= 2;

  bool get isIncomingUi => checkpointTimes % 2 == 0;

  bool get canEditFields => isIncomingUi && !_oneTimeDone;

  bool get showCheckInButton => isIncomingUi && !_oneTimeDone;

  bool get showCheckOutButton => !isIncomingUi && !_oneTimeDone;

  String get unitLabel {
    if (blockName.isNotEmpty && unitName.isNotEmpty) return '$blockName-$unitName';
    return unitName;
  }

  /// Android `VisitorDetailsActivity`: building office prefixes residence name.
  String unitDisplay({required bool strictBuildingOffice}) {
    final u = unitLabel.trim();
    if (strictBuildingOffice && residenceName.trim().isNotEmpty && u.isNotEmpty) {
      return '${residenceName.trim()}, $u';
    }
    return u;
  }

  String get maskedIcPassport {
    if (icPassport.isEmpty) return '';
    if (icPassport.length <= 4) return '****';
    final stars = List<String>.filled(icPassport.length - 4, '*').join();
    return '$stars${icPassport.substring(icPassport.length - 4)}';
  }
}
