import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Android `DBOthers` keys for incident categories (`incidents$userResidenceID`) + offline queue.
abstract final class ReportingPrefs {
  static const _pendingKey = 'kiple_reporting_pending_v1';
  static const _uuid = Uuid();

  static String incidentsCacheKey(String residenceId) => 'incidents$residenceId';

  static Future<String?> readIncidentCategories(String residenceId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(incidentsCacheKey(residenceId));
  }

  static Future<void> writeIncidentCategories(String residenceId, String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(incidentsCacheKey(residenceId), json);
  }

  static Future<void> clearForResidence(String residenceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(incidentsCacheKey(residenceId));
  }

  static Future<List<Map<String, dynamic>>> loadPendingQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) return [];
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> _saveQueue(List<Map<String, dynamic>> q) async {
    final prefs = await SharedPreferences.getInstance();
    if (q.isEmpty) {
      await prefs.remove(_pendingKey);
    } else {
      await prefs.setString(_pendingKey, jsonEncode(q));
    }
  }

  static Future<void> enqueue({
    required String residenceUuid,
    required String pin,
    required String incidentType,
    required String description,
    required String incidentAt,
    required List<String> imagePaths,
  }) async {
    final q = await loadPendingQueue();
    q.add(<String, dynamic>{
      'id': _uuid.v4(),
      'residence_uuid': residenceUuid,
      'pin': pin,
      'incident_type': incidentType,
      'description': description,
      'incident_at': incidentAt,
      'paths': imagePaths,
    });
    await _saveQueue(q);
  }

  static Future<void> dequeueFirst() async {
    final q = await loadPendingQueue();
    if (q.isEmpty) return;
    q.removeAt(0);
    await _saveQueue(q);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingKey);
    for (final k in prefs.getKeys()) {
      if (k.startsWith('incidents')) await prefs.remove(k);
    }
  }
}
