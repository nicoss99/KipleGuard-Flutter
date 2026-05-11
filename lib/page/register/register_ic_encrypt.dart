import 'package:encrypt/encrypt.dart' as enc;

/// Android `RegisterStep3HSAActivity` + `AESUtil.encrypt` (AES/CBC/PKCS5, IV = first 16 chars of uuid×2, key = first 32 chars of uuid×4).
String encryptIcForResidence(String plainIc, String residenceUuid) {
  if (plainIc.isEmpty || residenceUuid.isEmpty) return '';
  final doubled = '$residenceUuid$residenceUuid';
  if (doubled.length < 16) return '';
  final public16 = doubled.substring(0, 16);
  final quad = doubled + doubled;
  if (quad.length < 32) return '';
  final private32 = quad.substring(0, 32);
  final key = enc.Key.fromUtf8(private32);
  final iv = enc.IV.fromUtf8(public16);
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
  return encrypter.encrypt(plainIc, iv: iv).base64;
}
