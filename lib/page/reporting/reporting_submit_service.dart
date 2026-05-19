import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_logger.dart';
import 'reporting_prefs.dart';
import 'reporting_repository.dart';

final reportingSubmitServiceProvider = Provider<ReportingSubmitService>(
  (ref) => ReportingSubmitService(ref.watch(reportingRepositoryProvider)),
);

enum ReportingSubmitOutcome { synced, queued }

/// Android dashboard incident pipeline: upload → create → link images.
class ReportingSubmitService {
  ReportingSubmitService(this._repo);

  final ReportingRepository _repo;

  Future<ReportingSubmitOutcome> submit({
    required Map<String, dynamic> body,
    required List<String> imagePaths,
  }) async {
    final bodyCopy = Map<String, dynamic>.from(body);
    final files = imagePaths.map(File.new).where((f) => f.existsSync()).toList();

    try {
      if (files.isNotEmpty) {
        final uuids = await _repo.uploadIncidentFiles(files);
        bodyCopy['files'] = uuids;
      }
      final incidentUuid = await _repo.createIncidentReturnUuid(bodyCopy);
      final fileUuids = bodyCopy['files'];
      if (incidentUuid != null && fileUuids is List && fileUuids.isNotEmpty) {
        final asStrings = fileUuids.map((e) => e.toString()).toList();
        try {
          await _repo.linkIncidentFiles(incidentUuid: incidentUuid, fileUuids: asStrings);
        } catch (e, st) {
          AppLog.error('linkIncidentFiles', tag: 'Reporting', error: e, stackTrace: st);
        }
      }
      return ReportingSubmitOutcome.synced;
    } catch (e, st) {
      AppLog.error('Incident submit — queue offline', tag: 'Reporting', error: e, stackTrace: st);
      await ReportingPrefs.enqueue(body: body, imagePaths: imagePaths);
      return ReportingSubmitOutcome.queued;
    }
  }
}
