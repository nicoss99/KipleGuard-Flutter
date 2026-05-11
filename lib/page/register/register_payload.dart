import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/auth_prefs.dart';
import 'register_ic_encrypt.dart';
import 'register_models.dart';
import 'register_visitor_draft.dart';

const _uuid = Uuid();

/// Builds JSON for Android `RegisterStep3HSAActivity.submitVisitor` → `POST data/visitors`.
Future<Map<String, dynamic>> buildRegisterVisitorPayload({
  required String residenceUuid,
  required RegisterVisitorTypeOption visitorType,
  required RegisterUnitOption unit,
  required RegisterVisitorDraft visitor,
  required String passReference,
  required String startTimeUtc,
  required String? endTimeUtc,
  RegisterHostOption? host,
  required List<String> walkinPhotoUuids,
}) async {
  final profileUuid = await AuthPrefs.readProfileUuid() ?? '';
  final qrCode = _uuid.v4();
  final icPassport = encryptIcForResidence(visitor.icPassport.trim(), residenceUuid);
  final updateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());

  final body = <String, dynamic>{
    'ic_passport': icPassport,
    'name': visitor.name.trim(),
    'repeat_type': 'ONE_TIME',
    'date': startTimeUtc,
    'start_time': startTimeUtc,
    'end_time': endTimeUtc,
    'visit_type': 'VISITOR',
    'qr_code': qrCode,
    'checkpoint_times': '1',
    'status': 'VALID',
    'latest_scan_type': 'IN',
    'scanned_by': profileUuid,
    'visitor_type_uuid': visitorType.uuid,
    'created_by': profileUuid,
    'residence_uuid': residenceUuid,
    'unit_uuid': unit.unitUuid,
    'user_profile_uuid': host?.uuid,
    'host_name': host?.name,
    'host_mobile': host?.phone,
    'host_email': host?.email,
    'is_scanning_qr_code': false,
    'is_sending': false,
    'type': 'Guard',
    'category': visitorType.name,
    'walkin_photo': jsonEncode(walkinPhotoUuids),
    'car_plate_number': visitor.carPlate.trim(),
    'phone_number': visitor.mobile.trim(),
    'pass_reference_id': passReference.trim(),
    'company': visitor.company.trim(),
    'email': visitor.email.trim(),
    'visitor_fr_id': null,
    'visitor_url': null,
    'visitor_temp': visitor.temperature.trim(),
    'visitor_temp_updated_at': updateTime,
    'visitor_from': '',
    'visit_status': 'APPROVED',
  };

  body.removeWhere((k, v) => v == null);
  return body;
}

String? parseVisitorUuidFromRegisterResponse(dynamic data) {
  if (data is! Map) return null;
  final r = data['resource'];
  if (r is! List || r.isEmpty) return null;
  final first = r.first;
  if (first is! Map) return null;
  final u = first['uuid']?.toString();
  return (u != null && u.isNotEmpty) ? u : null;
}
