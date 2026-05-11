import 'register_models.dart';

/// UI labels for visit type (fixed list). Maps to `visitor_types` from API by name.
enum RegisterVisitKind {
  contractor,
  deliveryPickup,
  friendFamily;

  String get label => switch (this) {
    RegisterVisitKind.contractor => 'Contractor',
    RegisterVisitKind.deliveryPickup => 'Delivery / Pickup',
    RegisterVisitKind.friendFamily => 'Friend & Family',
  };

  static RegisterVisitKind? fromLabel(String label) {
    for (final k in RegisterVisitKind.values) {
      if (k.label == label) return k;
    }
    return null;
  }
}

/// Picks a `visitor_types` row similar to Android category spinner.
RegisterVisitorTypeOption? resolveVisitKind(RegisterVisitKind kind, List<RegisterVisitorTypeOption> api) {
  bool matches(String apiName, List<String> keys) {
    final l = apiName.toLowerCase();
    return keys.any(l.contains);
  }

  for (final t in api) {
    switch (kind) {
      case RegisterVisitKind.contractor:
        if (matches(t.name, ['contractor'])) return t;
      case RegisterVisitKind.deliveryPickup:
        if (matches(t.name, ['delivery', 'pickup', 'pick up'])) return t;
      case RegisterVisitKind.friendFamily:
        if (matches(t.name, ['friend', 'family'])) return t;
    }
  }
  return null;
}
