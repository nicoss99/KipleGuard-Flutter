import 'dart:developer' as developer;

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_logger.dart';
import 'reporting_prefs.dart';
import '../../core/api/contracts/guard_reporting_repository.dart';
import 'reporting_repository.dart';

final reportingSyncServiceProvider = Provider<ReportingSyncService>(
  (ref) => ReportingSyncService(ref.watch(reportingRepositoryProvider)),
);

class ReportingSyncService {
  ReportingSyncService(this._repo);

  final GuardReportingRepository _repo;

  Future<void> processQueue() async {
    for (;;) {
      final q = await ReportingPrefs.loadPendingQueue();
      if (q.isEmpty) return;
      final item = q.first;
      try {
        await _repo.createIncident(
          residenceUuid: item['residence_uuid'] as String,
          incidentType: item['incident_type'] as String,
          description: item['description'] as String,
          incidentAt: item['incident_at'] as String,
          photoPaths: (item['paths'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
        );
        await ReportingPrefs.dequeueFirst();
      } catch (e, st) {
        AppLog.error('Reporting queue sync failed', tag: 'Reporting', error: e, stackTrace: st);
        developer.log('Reporting sync paused: $e', name: 'KipleGuard.Reporting');
        return;
      }
    }
  }
}
