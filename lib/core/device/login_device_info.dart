import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Device fields for `POST api/v1/guard/auth/login`.
class LoginDeviceInfo {
  const LoginDeviceInfo({
    required this.deviceUniqueId,
    required this.deviceModel,
    required this.brand,
  });

  final String deviceUniqueId;
  final String deviceModel;
  final String brand;

  Map<String, dynamic> toLoginJson() => <String, dynamic>{
        'device_unique_id': deviceUniqueId,
        'device_model': deviceModel,
        'brand': brand,
      };
}

abstract final class LoginDeviceInfoReader {
  static const _prefsKey = 'guard_device_unique_id';

  static Future<LoginDeviceInfo> read() async {
    final uniqueId = await _readOrCreateUniqueId();
    final plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      return LoginDeviceInfo(
        deviceUniqueId: uniqueId,
        deviceModel: info.model.trim().isEmpty ? 'Android' : info.model,
        brand: info.brand.trim().isEmpty ? 'Android' : info.brand,
      );
    }
    if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      final model = info.utsname.machine.trim();
      return LoginDeviceInfo(
        deviceUniqueId: uniqueId,
        deviceModel: model.isEmpty ? 'iOS' : model,
        brand: 'Apple',
      );
    }
    return LoginDeviceInfo(
      deviceUniqueId: uniqueId,
      deviceModel: Platform.operatingSystem,
      brand: Platform.operatingSystem,
    );
  }

  static Future<String> _readOrCreateUniqueId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefsKey)?.trim();
    if (existing != null && existing.isNotEmpty) return existing;
    final id = const Uuid().v4();
    await prefs.setString(_prefsKey, id);
    return id;
  }
}
