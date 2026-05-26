/// Guard auth/profile DTOs (`/api/v1/guard/*`).
class GuardProfile {
  const GuardProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.role,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final String role;

  factory GuardProfile.fromJson(Map<String, dynamic> json) => GuardProfile(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        profileImageUrl: json['profile_image_url'] as String?,
        role: json['role'] as String? ?? '',
      );
}

class GuardResidence {
  const GuardResidence({
    required this.id,
    required this.uuid,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.postcode,
    this.imageUrl,
    required this.role,
    this.securityCompanyUuid,
  });

  final int id;
  final String uuid;
  final String name;
  final String address;
  final String city;
  final String state;
  final String postcode;
  final String? imageUrl;
  final String role;
  /// Android `DBOthers.securityUUID` / DreamFactory `security_company_uuid`.
  final String? securityCompanyUuid;

  factory GuardResidence.fromJson(Map<String, dynamic> json) => GuardResidence(
        id: json['id'] as int? ?? 0,
        uuid: json['uuid'] as String? ?? '',
        name: json['name'] as String? ?? '',
        address: json['address'] as String? ?? '',
        city: json['city'] as String? ?? '',
        state: json['state'] as String? ?? '',
        postcode: json['postcode'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        role: json['role'] as String? ?? '',
        securityCompanyUuid: json['security_company_uuid'] as String? ??
            json['securityCompanyUuid'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'postcode': postcode,
        'image_url': imageUrl,
        'role': role,
        if (securityCompanyUuid != null && securityCompanyUuid!.isNotEmpty)
          'security_company_uuid': securityCompanyUuid,
      };
}

class GuardSwitchDevice {
  const GuardSwitchDevice({
    required this.isSwitchDevice,
    this.previousDeviceLabel,
    this.message = '',
  });

  final bool isSwitchDevice;
  final String? previousDeviceLabel;
  final String message;

  factory GuardSwitchDevice.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const GuardSwitchDevice(isSwitchDevice: false);
    }
    return GuardSwitchDevice(
      isSwitchDevice: json['is_switch_device'] == true,
      previousDeviceLabel: json['previous_device_label'] as String?,
      message: json['message'] as String? ?? '',
    );
  }
}

class GuardLoginResult {
  const GuardLoginResult({this.switchDevice});

  final GuardSwitchDevice? switchDevice;
}

class GuardMeResult {
  const GuardMeResult({required this.guard, required this.residences});

  final GuardProfile guard;
  final List<GuardResidence> residences;
}
