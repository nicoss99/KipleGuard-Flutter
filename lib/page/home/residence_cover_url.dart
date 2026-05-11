/// Cover image URL from `GET data/residences` resource (`files_by_cover_photo` / `file` / legacy).
///
/// Android `DashboardActivity` uses [files_by_cover_photo.url]; `Resource` also has a top-level [file].
String extractResidenceCoverUrl(Map<String, dynamic> resource) {
  String? fromMap(Map<String, dynamic> map) {
    for (final key in ['url', 'preview']) {
      final v = map[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  dynamic cover = resource['files_by_cover_photo'];
  if (cover is List<dynamic> && cover.isNotEmpty) {
    cover = cover.first;
  }
  if (cover is Map<String, dynamic>) {
    final u = fromMap(cover);
    if (u != null) return u;
  }

  final file = resource['file'];
  if (file is Map<String, dynamic>) {
    final u = fromMap(file);
    if (u != null) return u;
  }

  final legacy = resource['cover_photo'];
  if (legacy is String && legacy.trim().isNotEmpty) return legacy.trim();
  return '';
}
