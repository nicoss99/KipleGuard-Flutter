import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_logger.dart';
import 'reporting_prefs.dart';
import 'reporting_repository.dart';

final reportingSubmitServiceProvider = Provider<ReportingSubmitService>(
  (ref) => ReportingSubmitService(ref.watch(reportingRepositoryProvider)),
);

enum ReportingSubmitOutcome { synced, queued }

class ReportingSubmitService {
  ReportingSubmitService(this._repo);

  final ReportingRepository _repo;

  Future<ReportingSubmitOutcome> submit({
    required String residenceUuid,
    required String incidentType,
    required String description,
    required String incidentAt,
    required List<String> imagePaths,
  }) async {
    try {
      await _repo.createIncident(
        residenceUuid: residenceUuid,
        incidentType: incidentType,
        description: description,
        incidentAt: incidentAt,
        photoPaths: imagePaths,
      );
      return ReportingSubmitOutcome.synced;
    } catch (e, st) {
      AppLog.error('Incident submit — queue offline', tag: 'Reporting', error: e, stackTrace: st);
      await ReportingPrefs.enqueue(
        residenceUuid: residenceUuid,
        incidentType: incidentType,
        description: description,
        incidentAt: incidentAt,
        imagePaths: imagePaths,
      );
      return ReportingSubmitOutcome.queued;
    }
  }
}
