import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../service/api_service.dart';

final unitCallRepositoryProvider = Provider<UnitCallRepository>(
  (ref) => UnitCallRepository(ref.watch(dioProvider)),
);

class UnitCallRepository {
  UnitCallRepository(this._dio);

  final Dio _dio;

  static String _cacheKey(String residenceUuid) => 'kiple_unit_resources_$residenceUuid';

  Future<List<Map<String, dynamic>>> loadCachedResources(String residenceUuid) async {
    if (residenceUuid.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey(residenceUuid));
    if (raw == null || raw.isEmpty) return [];
    try {
      final d = jsonDecode(raw);
      if (d is! List<dynamic>) return [];
      return d
          .map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCachedResources(String residenceUuid, List<Map<String, dynamic>> resources) async {
    if (residenceUuid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey(residenceUuid), jsonEncode(resources));
  }

  /// Android `RetrofitListAPI.unitListAPI` — paginated `meta.next`.
  Future<List<Map<String, dynamic>>> fetchAllResidenceUnits(String residenceUuid) async {
    final merged = <Map<String, dynamic>>[];
    var offset = 0;
    while (true) {
      final body = await _fetchPage(residenceUuid, offset);
      final resource = body['resource'];
      if (resource is List<dynamic>) {
        for (final e in resource) {
          if (e is Map<String, dynamic>) {
            merged.add(e);
          } else if (e is Map) {
            merged.add(Map<String, dynamic>.from(e));
          }
        }
      }
      int? next;
      final meta = body['meta'];
      if (meta is Map<String, dynamic>) {
        final n = meta['next'];
        if (n is num && n.toInt() > 0) {
          next = n.toInt();
        } else if (n is String) {
          next = int.tryParse(n);
        }
      }
      if (next == null || next <= 0) break;
      offset = next;
    }
    await saveCachedResources(residenceUuid, merged);
    return merged;
  }

  Future<Map<String, dynamic>> _fetchPage(String residenceUuid, int offset) async {
    final filter = '((deleted_at is null) AND (residence_uuid=$residenceUuid))';
    const order = 'block ASC,floor ASC,unit + 0';
    const related = 'residence_unit_memberships_by_unit_uuid';
    final res = await _dio.get<dynamic>(
      'data/residence_units',
      queryParameters: <String, dynamic>{
        'filter': filter,
        'order': order,
        'related': related,
        'include_count': 'true',
        'offset': '$offset',
        'limit': '50000',
      },
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    throw StateError('Invalid residence_units payload');
  }
}
