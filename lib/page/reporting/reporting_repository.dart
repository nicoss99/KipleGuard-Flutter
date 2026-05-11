import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../service/api_service.dart';

final reportingRepositoryProvider = Provider<ReportingRepository>(
  (ref) => ReportingRepository(ref.watch(dioProvider)),
);

/// Android `RetrofitInterface` incident endpoints + `RetrofitListAPI` helpers.
class ReportingRepository {
  ReportingRepository(this._dio);

  final Dio _dio;

  Future<String> fetchIncidentCategoriesRaw() async {
    final res = await _dio.get<dynamic>('data/kg_incident_categories');
    final data = res.data;
    if (data == null) return '{"resource":[]}';
    return jsonEncode(data);
  }

  Future<void> createIncident(Map<String, dynamic> body) async {
    await _dio.post<dynamic>('data/kg_incidents', data: body);
  }

  /// Returns first `resource[].uuid` from create response when present.
  Future<String?> createIncidentReturnUuid(Map<String, dynamic> body) async {
    final res = await _dio.post<dynamic>('data/kg_incidents', data: body);
    return _firstResourceUuid(res.data);
  }

  String? _firstResourceUuid(dynamic data) {
    if (data is Map<String, dynamic>) {
      final r = data['resource'];
      if (r is List && r.isNotEmpty && r.first is Map) {
        final u = (r.first as Map)['uuid'];
        if (u != null) return u.toString();
      }
    }
    return null;
  }

  /// `files/multiple/Kgguards` — returns JSON array (each item may be a JSON string or object).
  Future<List<String>> uploadIncidentFiles(List<File> files) async {
    final form = FormData();
    for (final f in files) {
      final name = '${DateTime.now().microsecondsSinceEpoch}_${f.path.hashCode}.jpg';
      form.files.add(MapEntry('files', await MultipartFile.fromFile(f.path, filename: name)));
    }
    final res = await _dio.post<dynamic>(
      'files/multiple/Kgguards',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return _parseUploadUuids(res.data);
  }

  Future<void> linkIncidentFiles({
    required String incidentUuid,
    required List<String> fileUuids,
  }) async {
    final arr = <Map<String, dynamic>>[];
    for (final u in fileUuids) {
      arr.add(<String, dynamic>{'file_uuid': u, 'incident_uuid': incidentUuid});
    }
    await _dio.post<dynamic>('data/kg_incident_images', data: arr);
  }

  List<String> _parseUploadUuids(dynamic data) {
    final out = <String>[];
    if (data is List) {
      for (final item in data) {
        if (item is String) {
          final m = jsonDecode(item);
          if (m is Map && m['uuid'] != null) out.add(m['uuid'].toString());
        } else if (item is Map && item['uuid'] != null) {
          out.add(item['uuid'].toString());
        }
      }
    }
    return out;
  }
}
