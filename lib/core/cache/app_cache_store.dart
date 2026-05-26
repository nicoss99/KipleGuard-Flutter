import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// JSON envelope persisted in [SharedPreferences] for offline reads.
class CacheEnvelope {
  const CacheEnvelope({required this.savedAt, required this.data});

  final DateTime savedAt;
  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'savedAt': savedAt.toUtc().toIso8601String(),
        'data': data,
      };

  static CacheEnvelope? fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return null;
      final at = map['savedAt']?.toString();
      final data = map['data'];
      if (at == null || data is! Map<String, dynamic>) return null;
      return CacheEnvelope(savedAt: DateTime.parse(at), data: data);
    } catch (_) {
      return null;
    }
  }
}

/// SharedPreferences-backed cache for guard list/detail payloads.
abstract final class AppCacheStore {
  static Future<void> write(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final envelope = CacheEnvelope(savedAt: DateTime.now(), data: data);
    final encoded = jsonEncode(envelope.toJson());
    final ok = await prefs.setString(key, encoded);
    if (ok != true) {
      await prefs.setString(key, encoded);
    }
  }

  static Future<CacheEnvelope?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return CacheEnvelope.fromJsonString(prefs.getString(key));
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> removeWhere(bool Function(String key) test) async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in prefs.getKeys()) {
      if (test(k)) await prefs.remove(k);
    }
  }
}
