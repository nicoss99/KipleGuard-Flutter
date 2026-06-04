import '../../core/guard_time_format.dart';
import '../register/register_ic_encrypt.dart';
import 'visitor_repository.dart';

Future<void> patchVisitorFromForm({
  required VisitorRepository repo,
  required String visitorUuid,
  required String residenceUuid,
  required String name,
  required String car,
  required String pass,
  required String parking,
  required String phone,
  required String temp,
  required String from,
  required String icPlain,
}) async {
  final body = <String, dynamic>{
    'car_plate_number': car,
    'pass_reference_id': pass,
    'parking_lot': parking,
    'name': name,
    'phone_number': phone,
  };
  if (icPlain.trim().isNotEmpty) {
    body['ic_passport'] = encryptIcForResidence(icPlain.trim(), residenceUuid);
  }
  if (temp.trim().isNotEmpty) {
    body['visitor_temp'] = temp.trim();
    body['visitor_temp_updated_at'] =
        GuardTimeFormat.apiDateTimeSeconds.format(DateTime.now().toUtc());
  }
  if (from.trim().isNotEmpty) {
    body['visitor_from'] = from.trim();
  }
  await repo.patchVisitor(visitorUuid, body);
}
