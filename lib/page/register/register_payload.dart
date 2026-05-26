import 'package:dio/dio.dart';

import 'register_models.dart';
import 'register_visitor_draft.dart';

/// Builds multipart body for `POST /api/v1/guard/residences/{scopeUuid}/visitors`.
Future<FormData> buildRegisterVisitorPayload({
  required RegisterVisitorTypeOption visitorType,
  required RegisterUnitOption unit,
  required RegisterVisitorDraft visitor,
  required String passReference,
  required String purpose,
  required String photoPath,
  RegisterHostOption? host,
}) async {
  final idString = visitorType.id?.toString() ?? visitorType.uuid.trim();
  final map = <String, dynamic>{
    'visitor_type_id': idString,
    'unit_uuid': unit.unitUuid.trim(),
    'visitor_name': visitor.name.trim(),
    'phone': visitor.mobile.trim(),
    'ic_passport_no': visitor.icPassport.trim(),
    'email': visitor.email.trim(),
    'temperature': visitor.temperature.trim(),
    'pass_id': passReference.trim(),
    'vehicle_number': visitor.carPlate.trim(),
    'purpose': purpose.trim(),
    'photo': await MultipartFile.fromFile(photoPath, filename: 'visitor.jpg'),
  };
  final hostId = host?.userId ?? int.tryParse(host?.uuid ?? '');
  if (hostId != null) {
    map['guest_of_user_id'] = hostId.toString();
  }
  map.removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));
  return FormData.fromMap(map);
}

String? parseVisitorUuidFromRegisterResponse(dynamic data) {
  if (data is! Map) return null;
  final payload = data['data'];
  if (payload is Map) {
    final visitor = payload['visitor'];
    if (visitor is Map) {
      final u = visitor['uuid']?.toString();
      if (u != null && u.isNotEmpty) return u;
    }
  }
  final legacy = data['resource'];
  if (legacy is List && legacy.isNotEmpty && legacy.first is Map) {
    final u = (legacy.first as Map)['uuid']?.toString();
    if (u != null && u.isNotEmpty) return u;
  }
  return null;
}
