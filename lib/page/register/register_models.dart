class RegisterBuildingRow {
  const RegisterBuildingRow({
    required this.uuid,
    required this.companyUuid,
    required this.name,
  });

  final String uuid;
  final String companyUuid;
  final String name;
}

class RegisterVisitorTypeOption {
  const RegisterVisitorTypeOption({
    required this.uuid,
    required this.name,
    this.isLprEnabled = false,
    this.isAllowDays = false,
    this.allowDays,
    this.mustLeaveBefore,
    this.mustLeaveIn,
    this.mustLeaveInMin,
    this.mustLeaveBeforeDay,
  });

  final String uuid;
  final String name;
  final bool isLprEnabled;
  final bool isAllowDays;
  final String? allowDays;
  final String? mustLeaveBefore;
  final int? mustLeaveIn;
  final int? mustLeaveInMin;
  final int? mustLeaveBeforeDay;
}

class RegisterUnitOption {
  const RegisterUnitOption({
    required this.unitUuid,
    required this.unitName,
    required this.blockName,
  });

  final String unitUuid;
  final String unitName;
  final String blockName;
}

class RegisterHostOption {
  const RegisterHostOption({
    required this.uuid,
    required this.name,
    this.email,
    this.phone,
  });

  final String uuid;
  final String name;
  final String? email;
  final String? phone;
}
