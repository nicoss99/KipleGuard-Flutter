import 'package:encrypt/encrypt.dart' as enc;

enc.Key _icAesKey(String residenceUuid) {
  final doubled = '$residenceUuid$residenceUuid';
  if (doubled.length < 16) throw StateError('residenceUuid too short');
  final quad = doubled + doubled;
  if (quad.length < 32) throw StateError('residenceUuid too short');
  final private32 = quad.substring(0, 32);
  return enc.Key.fromUtf8(private32);
}

enc.IV _icIv(String residenceUuid) {
  final doubled = '$residenceUuid$residenceUuid';
  final public16 = doubled.substring(0, 16);
  return enc.IV.fromUtf8(public16);
}

/// Android `RegisterStep3HSAActivity` + `AESUtil.encrypt` (AES/CBC/PKCS5, IV = first 16 chars of uuid×2, key = first 32 chars of uuid×4).
String encryptIcForResidence(String plainIc, String residenceUuid) {
  if (plainIc.isEmpty || residenceUuid.isEmpty) return '';
  try {
    final key = _icAesKey(residenceUuid);
    final iv = _icIv(residenceUuid);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.encrypt(plainIc, iv: iv).base64;
  } catch (_) {
    return '';
  }
}

/// Android `ListBookingDetailsActivity` + `AESUtil.decrypt` for `auth_person_ic`.
String decryptIcForResidence(String cipherB64, String residenceUuid) {
  if (cipherB64.isEmpty || residenceUuid.isEmpty) return '';
  try {
    final key = _icAesKey(residenceUuid);
    final iv = _icIv(residenceUuid);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.decrypt64(cipherB64, iv: iv);
  } catch (_) {
    return '';
  }
}
