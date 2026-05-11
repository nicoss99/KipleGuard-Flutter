import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'visitor_detail_fields.dart';
import 'visitor_repository.dart';

final visitorDetailProvider = FutureProvider.autoDispose.family<VisitorDetailFields?, String>((ref, visitorUuid) async {
  final raw = await ref.watch(visitorRepositoryProvider).fetchVisitorDetails(visitorUuid);
  if (raw == null) return null;
  return VisitorDetailFields.fromResource(raw);
});
