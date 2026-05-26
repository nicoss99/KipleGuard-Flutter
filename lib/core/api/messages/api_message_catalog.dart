/// Localized fallback messages when the API body has no `message` (DIP for repositories).
abstract interface class ApiMessageCatalog {
  String get somethingWentWrong;
  String get requestFailed;
  String get networkError;
  String get loginFailed;
  String get invalidLoginPayload;
  String get invalidCredentials;
  String get logoutFailed;
  String get profileLoadFailed;
  String get residencesLoadFailed;
  String get attendanceLoadFailed;
  String get invalidAttendancePayload;
  String get visitorLoadFailed;
  String get visitorDetailLoadFailed;
  String get scanFailed;
  String get incidentTypesLoadFailed;
  String get incidentReportFailed;
  String get visitorTypesLoadFailed;
}
