/// Result from ID scan (Android `Camera2Activity` OCR fields).
class RegisterIdScanResult {
  const RegisterIdScanResult({this.ic12, this.name});
  final String? ic12;
  final String? name;
}

/// Visitor form state (Android `AddVisitorActivity` companion fields).
class RegisterVisitorDraft {
  const RegisterVisitorDraft({
    this.name = '',
    this.mobile = '',
    this.email = '',
    this.company = '',
    this.carPlate = '',
    this.icPassport = '',
    this.temperature = '',
  });

  final String name;
  final String mobile;
  final String email;
  final String company;
  final String carPlate;
  final String icPassport;
  final String temperature;

  RegisterVisitorDraft copyWith({
    String? name,
    String? mobile,
    String? email,
    String? company,
    String? carPlate,
    String? icPassport,
    String? temperature,
  }) {
    return RegisterVisitorDraft(
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      company: company ?? this.company,
      carPlate: carPlate ?? this.carPlate,
      icPassport: icPassport ?? this.icPassport,
      temperature: temperature ?? this.temperature,
    );
  }
}

/// Extra for [RegisterVisitorDetailsPage] (`go_router`).
class RegisterVisitorDetailsArgs {
  const RegisterVisitorDetailsArgs({
    required this.lprRequired,
    required this.officeEnvironment,
    this.initial,
  });

  final bool lprRequired;
  final bool officeEnvironment;
  final RegisterVisitorDraft? initial;
}
