import 'visitor_detail_fields.dart';

/// Visitor detail load result (network or device cache).
class VisitorDetailSnapshot {
  const VisitorDetailSnapshot({
    required this.fields,
    this.fromCache = false,
    this.cacheSavedAt,
  });

  final VisitorDetailFields fields;
  final bool fromCache;
  final DateTime? cacheSavedAt;
}
