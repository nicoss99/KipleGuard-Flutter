/// Parses guard visitor list `data` payloads from `GET .../visitors`.
List<dynamic>? visitorListFromPayload(
  Map<String, dynamic>? data, {
  String? requestedStatus,
}) {
  if (data == null) return null;
  final responseStatus = data['status']?.toString();
  final keys = <String>{
    if (requestedStatus != null && requestedStatus.isNotEmpty) requestedStatus,
    if (responseStatus != null && responseStatus.isNotEmpty) responseStatus,
    'all_visitors',
    'visitors',
    'overtime',
    'checked_in',
    'upcoming',
  };
  for (final key in keys) {
    final raw = data[key];
    if (raw is List) return raw;
  }
  return null;
}
