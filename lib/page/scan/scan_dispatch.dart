import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_logger.dart';
import '../../core/dashboard_prefs.dart';
import '../auth/guard_visitor_repository.dart';
import 'scan_repository.dart';

final scanDispatcherProvider = Provider<ScanDispatcher>(
  (ref) => ScanDispatcher(ref),
);

/// Outcome of Android [QRScanActivity] pipeline (first match wins).
sealed class ScanDispatch {
  const ScanDispatch();
}

final class ScanDispatchVisitor extends ScanDispatch {
  const ScanDispatchVisitor(this.visitorUuid);
  final String visitorUuid;
}

final class ScanDispatchBooking extends ScanDispatch {
  const ScanDispatchBooking(this.bookingUuid);
  final String bookingUuid;
}

/// Opens [ScanHealthResultPage] with payload (temperature / guardian flow).
final class ScanDispatchHealth extends ScanDispatch {
  const ScanDispatchHealth(this.payload);
  final Map<String, dynamic> payload;
}

final class ScanDispatchForm extends ScanDispatch {
  const ScanDispatchForm(this.applicationUuid);
  final String applicationUuid;
}

class ScanDispatcher {
  ScanDispatcher(this._ref);

  final Ref _ref;

  Future<ScanDispatch?> dispatch(String qr) async {
    final raw = qr.trim();
    if (raw.isEmpty) return null;
    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) return null;

    final guardVisitors = _ref.read(guardVisitorRepositoryProvider);
    final repo = _ref.read(scanRepositoryProvider);

    try {
      final scan = await guardVisitors.scanVisitor(
        residenceUuid: snap.residenceId,
        qrCodeData: raw,
      );
      return ScanDispatchVisitor(scan.visitorId.toString());
    } catch (e, st) {
      AppLog.error('Guard visitor scan', tag: 'Scan', error: e, stackTrace: st);
    }

    try {
      final visitorUuid = await repo.scanQrVisitorUuid(
        residenceUuid: snap.residenceId,
        qrRaw: raw,
      );
      if (visitorUuid != null && visitorUuid.isNotEmpty) {
        return ScanDispatchVisitor(visitorUuid);
      }
    } catch (e, st) {
      AppLog.error('ScanQR visitor legacy', tag: 'Scan', error: e, stackTrace: st);
    }

    try {
      final books = await repo.fetchBookingsByQr(residenceUuid: snap.residenceId, qr: raw);
      if (books.isNotEmpty) {
        final u = books.first['uuid']?.toString();
        if (u != null && u.isNotEmpty) return ScanDispatchBooking(u);
      }
    } catch (e, st) {
      AppLog.error('ScanQR booking', tag: 'Scan', error: e, stackTrace: st);
    }

    final parts = splitQrCsv(raw);
    if (parts.isNotEmpty) {
      var r = '', u = '', p = '', f = '', parent = '';
      for (var i = 0; i < parts.length; i++) {
        final t = parts[i];
        if (r.isEmpty) {
          r = t;
        } else if (u.isEmpty) {
          u = t;
        } else if (p.isEmpty) {
          p = t;
        } else if (f.isEmpty) {
          f = t;
        } else if (parent.isEmpty) {
          parent = t;
        }
      }

      if (u.isEmpty || u == 'null') {
        try {
          if (parent.isNotEmpty) {
            final filter =
                '((deleted_at is null) AND (uuid=$p) AND (school_uuid=$r) AND (parent_uuid=$parent))';
            final list = await repo.fetchGuardianStudent(filter: filter);
            if (list.isNotEmpty) {
              return ScanDispatchHealth(_studentPayload(raw, list.first));
            }
          }
        } catch (e, st) {
          AppLog.error('ScanQR guardian', tag: 'Scan', error: e, stackTrace: st);
        }
      }

      if (snap.hdfEnabled == 'false' && snap.healthCodeEnabled == 'true') {
        try {
          final body = <String, dynamic>{
            'residence_uuid': r,
            'user_profile_uuid': p,
            'unit_uuid': (u.isEmpty || u == 'null') ? null : u,
            'staff_fr_id': (f.isEmpty || f == 'null') ? null : f,
          };
          final json = await repo.postHealthTemperatureLookup(body);
          final h = _parseTempResponse(raw, json);
          if (h != null) return ScanDispatchHealth(h);
        } catch (e, st) {
          AppLog.error('ScanQR getUserTemp', tag: 'Scan', error: e, stackTrace: st);
        }
      } else if (snap.hdfEnabled == 'true') {
        try {
          final resFilter = buildFormResidenceFilter(
            residenceUuid: snap.residenceId,
            officeEnable: snap.officeEnable,
            buildingResidencesJson: snap.buildingResidencesJson,
          );
          final formFilter =
              '($resFilter AND (staff_hdf_enabled=1) AND ((qr_code=$raw) OR (uuid=$raw)))';
          final forms = await repo.fetchApplications(filter: formFilter);
          if (forms.isNotEmpty) {
            final fu = forms.first['uuid']?.toString();
            if (fu != null && fu.isNotEmpty) return ScanDispatchForm(fu);
          }
        } catch (e, st) {
          AppLog.error('ScanQR formList', tag: 'Scan', error: e, stackTrace: st);
        }
      }
    }

    return null;
  }
}

Map<String, dynamic> _studentPayload(String qr, Map<String, dynamic> row) {
  String? year;
  String? cls;
  final sy = row['school_years_by_year_id'];
  if (sy is Map) year = sy['year_name']?.toString();
  final c = row['classes_by_class_uuid'];
  if (c is Map) cls = c['name']?.toString();
  return <String, dynamic>{
    'parent_student_qr': true,
    'qr_code_string': qr,
    'body_temperature': 0.0,
    'check_time': '',
    'staff_fr_id': null,
    'student_name': row['name']?.toString(),
    'student_year': year,
    'student_class': cls,
  };
}

Map<String, dynamic>? _parseTempResponse(String qr, Map<String, dynamic>? json) {
  if (json == null) return null;
  final resource = json['resource'];
  if (resource is List && resource.isNotEmpty && resource.first is Map) {
    final m = Map<String, dynamic>.from(resource.first as Map);
    var staffFrId = m['staff_fr_id']?.toString();
    staffFrId ??= m['user_id']?.toString();
    final temp = (m['body_temperature'] as num?)?.toDouble();
    final checkTime = m['check_time']?.toString();
    if ((staffFrId != null && (temp == null || temp <= 0)) || (temp != null && temp > 0)) {
      return <String, dynamic>{
        'parent_student_qr': false,
        'qr_code_string': qr,
        'body_temperature': temp,
        'check_time': checkTime ?? '',
        'staff_fr_id': staffFrId,
        'student_name': null,
        'student_year': null,
        'student_class': null,
      };
    }
  }
  final code = json['code'];
  if (code == 200) {
    return <String, dynamic>{
      'parent_student_qr': false,
      'qr_code_string': qr,
      'body_temperature': 0.0,
      'check_time': '',
      'staff_fr_id': null,
      'student_name': null,
      'student_year': null,
      'student_class': null,
    };
  }
  return null;
}
