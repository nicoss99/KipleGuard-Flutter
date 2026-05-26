import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/cache/app_cache_store.dart';
import '../../../core/cache/guard_cache_keys.dart';
import '../../../service/api_service.dart';
final callRecentRepositoryProvider = Provider<CallRecentRepository>(
  (ref) => CallRecentRepository(ref.watch(dioProvider)),
);

class CallRecentCacheSnapshot {
  const CallRecentCacheSnapshot({required this.savedAt, required this.resource});

  final DateTime savedAt;
  final List<Map<String, dynamic>> resource;
}

class CallRecentRepository {
  CallRecentRepository(this._dio);

  final Dio _dio;

  /// Android `RetrofitListAPI.voipRefreshHistoryAPI` — last ~3 months UTC date.
  static String _filterDateUtc() {
    final n = DateTime.now().toUtc();
    var y = n.year;
    var m = n.month - 3;
    while (m < 1) {
      m += 12;
      y -= 1;
    }
    final cut = DateTime.utc(y, m, n.day);
    return DateFormat('yyyy-MM-dd').format(cut);
  }

  static const _related =
      'user_profiles_by_receiver_profile_uuid, residence_units_by_unit_uuid, residences_by_residence_uuid';

  Future<CallRecentCacheSnapshot?> loadCached(String residenceUuid) async {
    if (residenceUuid.isEmpty) return null;
    final env = await AppCacheStore.read(GuardCacheKeys.callHistory(residenceUuid));
    if (env != null) {
      final resource = _parseResourceList(env.data['resource']);
      if (resource != null) {
        return CallRecentCacheSnapshot(savedAt: env.savedAt, resource: resource);
      }
    }
    return _loadLegacyCallHistory(residenceUuid);
  }

  static List<Map<String, dynamic>>? _parseResourceList(Object? raw) {
    if (raw is! List) return null;
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<CallRecentCacheSnapshot?> _loadLegacyCallHistory(String residenceUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final legacyKey = GuardCacheKeys.legacyCallHistory(residenceUuid);
    final raw = prefs.getString(legacyKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      List<Map<String, dynamic>>? resource;
      if (decoded is List) {
        resource = _parseResourceList(decoded);
      } else if (decoded is Map<String, dynamic>) {
        resource = _parseResourceList(decoded['resource']);
      }
      if (resource == null || resource.isEmpty) return null;
      await AppCacheStore.write(
        GuardCacheKeys.callHistory(residenceUuid),
        <String, dynamic>{'resource': resource},
      );
      await prefs.remove(legacyKey);
      return CallRecentCacheSnapshot(savedAt: DateTime.now(), resource: resource);
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchHistory(String residenceUuid) async {
    if (residenceUuid.isEmpty) return [];
    final cut = _filterDateUtc();
    final filter = '((deleted_at is null) AND (residence_uuid=$residenceUuid) AND (call_at >= $cut))';
    const order = 'call_at ASC';
    final res = await _dio.get<dynamic>(
      'data/call_history',
      queryParameters: <String, dynamic>{
        'related': _related,
        'filter': filter,
        'order': order,
      },
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid call_history payload');
    }
    final resource = data['resource'];
    if (resource is! List<dynamic>) return [];
    final maps = resource.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    await AppCacheStore.write(
      GuardCacheKeys.callHistory(residenceUuid),
      <String, dynamic>{'resource': maps},
    );
    return maps;
  }
}
