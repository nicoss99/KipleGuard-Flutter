import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists in-call navigation (block/floor/unit, search, expanded rows) per residence.
abstract final class UnitCallSessionPrefs {
  static const sessionKey = 'kiple_unit_call_session';

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionKey);
  }

  static Future<Map<String, dynamic>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final d = jsonDecode(raw);
      if (d is Map<String, dynamic>) return d;
      if (d is Map) return Map<String, dynamic>.from(d);
    } catch (_) {}
    return null;
  }

  static Future<void> write(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sessionKey, jsonEncode(json));
  }
}
