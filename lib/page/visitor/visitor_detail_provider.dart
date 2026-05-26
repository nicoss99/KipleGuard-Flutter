import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/dashboard_prefs.dart';
import '../auth/guard_visitor_repository.dart';
import 'visitor_detail_fields.dart';

final visitorDetailProvider = FutureProvider.autoDispose.family<VisitorDetailFields?, String>((ref, visitorUuid) async {
  final visitorId = int.tryParse(visitorUuid);
  if (visitorId == null) return null;

  final snap = await DashboardPrefs.loadSnapshot();
  if (snap.residenceId.isEmpty) return null;

  final raw = await ref.read(guardVisitorRepositoryProvider).fetchVisitorById(
    snap.residenceId,
    visitorId: visitorId,
  );
  if (raw == null) return null;

  return VisitorDetailFields.fromGuardJson(
    raw,
    residenceUuid: snap.residenceId,
    residenceName: snap.residenceName,
  );
});
