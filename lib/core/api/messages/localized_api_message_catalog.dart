import 'dart:ui' show Locale;

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import 'api_message_catalog.dart';

final apiMessageCatalogProvider = Provider<ApiMessageCatalog>(
  (ref) => LocalizedApiMessageCatalog(lookupAppLocalizations(const Locale('en'))),
);

final class LocalizedApiMessageCatalog implements ApiMessageCatalog {
  LocalizedApiMessageCatalog(this._l10n);

  final AppLocalizations _l10n;

  @override
  String get somethingWentWrong => _l10n.apiSomethingWentWrong;

  @override
  String get requestFailed => _l10n.apiRequestFailed;

  @override
  String get networkError => _l10n.apiNetworkError;

  @override
  String get loginFailed => _l10n.apiLoginFailed;

  @override
  String get invalidLoginPayload => _l10n.apiInvalidLoginPayload;

  @override
  String get invalidCredentials => _l10n.apiInvalidCredentials;

  @override
  String get logoutFailed => _l10n.apiLogoutFailed;

  @override
  String get profileLoadFailed => _l10n.apiProfileLoadFailed;

  @override
  String get residencesLoadFailed => _l10n.apiResidencesLoadFailed;

  @override
  String get attendanceLoadFailed => _l10n.apiAttendanceLoadFailed;

  @override
  String get invalidAttendancePayload => _l10n.apiInvalidAttendancePayload;

  @override
  String get visitorLoadFailed => _l10n.apiVisitorLoadFailed;

  @override
  String get visitorDetailLoadFailed => _l10n.apiVisitorDetailLoadFailed;

  @override
  String get scanFailed => _l10n.apiScanFailed;

  @override
  String get incidentTypesLoadFailed => _l10n.apiIncidentTypesLoadFailed;

  @override
  String get incidentReportFailed => _l10n.apiIncidentReportFailed;

  @override
  String get visitorTypesLoadFailed => _l10n.apiVisitorTypesLoadFailed;
}
