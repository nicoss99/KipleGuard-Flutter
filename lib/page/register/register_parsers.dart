import 'dart:convert';

import 'register_models.dart';

int? _intOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

/// Android `CreateVisitActivity.addCategory` / `visitor_types` resource rows.
List<RegisterVisitorTypeOption> parseVisitorTypeOptions(String json) {
  if (json.isEmpty) return [];
  try {
    final d = jsonDecode(json);
    final resource = d is Map<String, dynamic> ? d['resource'] : null;
    if (resource is! List<dynamic>) return [];
    final out = <RegisterVisitorTypeOption>[];
    for (final raw in resource) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final uuid = m['uuid']?.toString();
      final name = m['name']?.toString();
      if (uuid == null || uuid.isEmpty || name == null) continue;
      out.add(
        RegisterVisitorTypeOption(
          uuid: uuid,
          name: name,
          isLprEnabled: m['is_lpr_enabled'] == true,
          isAllowDays: m['is_allow_days'] == true,
          allowDays: m['allow_days']?.toString(),
          mustLeaveBefore: m['must_leave_before']?.toString(),
          mustLeaveIn: _intOrNull(m['must_leave_in']),
          mustLeaveInMin: _intOrNull(m['must_leave_in_min']),
          mustLeaveBeforeDay: _intOrNull(m['must_leave_before_day']),
        ),
      );
    }
    return out;
  } catch (_) {
    return [];
  }
}

/// Android `ListBuildingResidenceActivity` / `buildingResidences` JSON array.
List<RegisterBuildingRow> parseBuildingRows(String json) {
  if (json.isEmpty || json == '[]') return [];
  try {
    final d = jsonDecode(json);
    if (d is! List<dynamic>) return [];
    final out = <RegisterBuildingRow>[];
    for (final raw in d) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final company = m['company_uuid']?.toString() ?? '';
      if (company.isEmpty) continue;
      out.add(
        RegisterBuildingRow(
          uuid: m['uuid']?.toString() ?? '',
          companyUuid: company,
          name: m['name']?.toString() ?? company,
        ),
      );
    }
    return out;
  } catch (_) {
    return [];
  }
}

List<RegisterHostOption> parseUnitMembersResponse(dynamic data) {
  if (data is! Map<String, dynamic>) return [];
  final list = data['data'];
  if (list is! List<dynamic>) return [];
  final out = <RegisterHostOption>[];
  for (final raw in list) {
    if (raw is! Map) continue;
    final m = Map<String, dynamic>.from(raw);
    final uuid = m['uuid']?.toString() ?? '';
    if (uuid.isEmpty) continue;
    out.add(
      RegisterHostOption(
        uuid: uuid,
        name: m['name']?.toString() ?? '',
        email: m['email']?.toString(),
        phone: m['phone']?.toString(),
      ),
    );
  }
  return out;
}
