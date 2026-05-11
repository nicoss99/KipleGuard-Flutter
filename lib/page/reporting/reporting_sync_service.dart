import 'dart:developer' as developer;
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_logger.dart';
import 'reporting_prefs.dart';
import 'reporting_repository.dart';

final reportingSyncServiceProvider = Provider<ReportingSyncService>(
  (ref) => ReportingSyncService(ref.watch(reportingRepositoryProvider)),
);

/// Mirrors Android `DashboardActivity.refreshReport` / incident pipeline (simplified).
class ReportingSyncService {
  ReportingSyncService(this._repo);

  final ReportingRepository _repo;

  Future<void> processQueue() async {
    for (;;) {
      final q = await ReportingPrefs.loadPendingQueue();
      if (q.isEmpty) return;
      final item = q.first;
      try {
        final body = Map<String, dynamic>.from(item['body'] as Map);
        final paths = (item['paths'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
        final files = paths.map(File.new).where((f) => f.existsSync()).toList();
        if (files.isNotEmpty) {
          final uuids = await _repo.uploadIncidentFiles(files);
          body['files'] = uuids;
        }
        final incidentUuid = await _repo.createIncidentReturnUuid(body);
        final fileUuids = body['files'];
        if (incidentUuid != null && fileUuids is List && fileUuids.isNotEmpty) {
          final asStrings = fileUuids.map((e) => e.toString()).toList();
          try {
            await _repo.linkIncidentFiles(incidentUuid: incidentUuid, fileUuids: asStrings);
          } catch (e, st) {
            AppLog.error('linkIncidentFiles', tag: 'Reporting', error: e, stackTrace: st);
          }
        }
        await ReportingPrefs.dequeueFirst();
      } catch (e, st) {
        AppLog.error('Reporting queue sync failed', tag: 'Reporting', error: e, stackTrace: st);
        developer.log('Reporting sync paused: $e', name: 'KipleGuard.Reporting');
        return;
      }
    }
  }
}
