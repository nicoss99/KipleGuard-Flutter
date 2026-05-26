import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/cache/guard_detail_cache.dart';
import '../../core/connectivity/connectivity_refresh.dart';
import '../../core/dashboard_prefs.dart';
import '../../core/network/dio_network.dart';
import '../../core/offline/offline_messages.dart';
import '../auth/guard_visitor_repository.dart';
import 'visitor_detail_fields.dart';
import 'visitor_detail_snapshot.dart';

final visitorDetailProvider =
    FutureProvider.autoDispose.family<VisitorDetailSnapshot?, String>((ref, visitorUuid) async {
  final visitorId = int.tryParse(visitorUuid);
  if (visitorId == null) return null;

  final snap = await DashboardPrefs.loadSnapshot();
  if (snap.residenceId.isEmpty) return null;

  Future<VisitorDetailSnapshot?> fromCache() async {
    final cached = await GuardDetailCache.readVisitorDetail(
      residenceUuid: snap.residenceId,
      visitorId: visitorId,
    );
    if (cached == null) return null;
    return VisitorDetailSnapshot(
      fields: VisitorDetailFields.fromGuardJson(
        cached.visitor,
        residenceUuid: snap.residenceId,
        residenceName: cached.residenceName.isNotEmpty
            ? cached.residenceName
            : snap.residenceName,
      ),
      fromCache: true,
      cacheSavedAt: cached.savedAt,
    );
  }

  if (!await isDeviceOnline(ref)) {
    final cached = await fromCache();
    if (cached != null) return cached;
    throw StateError(offlineNoCachedDataMessage());
  }

  try {
    final raw = await ref.read(guardVisitorRepositoryProvider).fetchVisitorById(
          snap.residenceId,
          visitorId: visitorId,
        );
    if (raw == null) {
      final cached = await fromCache();
      if (cached != null) return cached;
      return null;
    }
    await GuardDetailCache.saveVisitorDetail(
      residenceUuid: snap.residenceId,
      visitorId: visitorId,
      visitorJson: raw,
      residenceName: snap.residenceName,
    );
    return VisitorDetailSnapshot(
      fields: VisitorDetailFields.fromGuardJson(
        raw,
        residenceUuid: snap.residenceId,
        residenceName: snap.residenceName,
      ),
    );
  } on DioException catch (e) {
    if (isNetworkError(e)) return fromCache();
    rethrow;
  }
});
