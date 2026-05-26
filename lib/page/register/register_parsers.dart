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
    List<dynamic>? resource;
    if (d is Map<String, dynamic>) {
      final data = d['data'];
      if (data is Map<String, dynamic> && data['visitor_types'] is List<dynamic>) {
        resource = data['visitor_types'] as List<dynamic>;
      } else if (d['resource'] is List<dynamic>) {
        resource = d['resource'] as List<dynamic>;
      }
    }
    if (resource == null) return [];
    final out = <RegisterVisitorTypeOption>[];
    for (final raw in resource) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final id = _intOrNull(m['id']);
      final uuid = m['uuid']?.toString() ?? id?.toString();
      final name = m['name']?.toString();
      if (uuid == null || uuid.isEmpty || name == null) continue;
      out.add(
        RegisterVisitorTypeOption(
          id: id,
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
        userId: _intOrNull(m['user_id']) ?? _intOrNull(m['id']),
        email: m['email']?.toString(),
        phone: m['phone']?.toString(),
      ),
    );
  }
  return out;
}

List<RegisterVisitorTypeOption> parseVisitorTypeOptionsFromApi(
  Map<String, dynamic>? body,
) {
  if (body == null) return const [];
  final data = body['data'];
  if (data is! Map<String, dynamic>) return const [];
  final raw = data['visitor_types'];
  if (raw is! List<dynamic>) return const [];
  final out = <RegisterVisitorTypeOption>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final m = Map<String, dynamic>.from(item);
    final id = _intOrNull(m['id']);
    final uuid = id?.toString() ?? m['uuid']?.toString() ?? '';
    final name = m['label']?.toString() ?? m['name']?.toString() ?? '';
    if (uuid.isEmpty || name.isEmpty) continue;
    out.add(
      RegisterVisitorTypeOption(
        id: id,
        uuid: uuid,
        name: name,
      ),
    );
  }
  return out;
}
