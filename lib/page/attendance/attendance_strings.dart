import '../../l10n/app_l10n.dart';

/// Localized via [appL10n] — keys in `lib/l10n/app_en.arb`.
abstract final class AttendanceStrings {
  static String get titleTaking => appL10n.attendanceTitleTaking;
  static String get titleRecords => appL10n.attendanceTitleRecords;
  static String get tabTaking => appL10n.attendanceTabTaking;
  static String get tabRecords => appL10n.attendanceTabRecords;
  static String get startShiftTitle => appL10n.attendanceStartShiftTitle;
  static String get startShiftSubtitle => appL10n.attendanceStartShiftSubtitle;
  static String get endShiftTitle => appL10n.attendanceEndShiftTitle;
  static String get endShiftSubtitle => appL10n.attendanceEndShiftSubtitle;
  static String get shiftStarted => appL10n.attendanceShiftStarted;
  static String get shiftEnded => appL10n.attendanceShiftEnded;
  static String get shiftStartedMessage => appL10n.attendanceShiftStartedMessage;
  static String get shiftEndedMessage => appL10n.attendanceShiftEndedMessage;
  static String get successDone => appL10n.attendanceSuccessDone;
  static String get invalidPin => appL10n.attendanceInvalidPin;
  static String get noResidenceSelected => appL10n.attendanceNoResidenceSelected;
  static String get missingSecurityProfile => appL10n.attendanceMissingSecurityProfile;
  static String get shiftAlreadyStarted => appL10n.attendanceShiftAlreadyStarted;
  static String get shiftAlreadyEnded => appL10n.attendanceShiftAlreadyEnded;
  static String get recordsEmpty => appL10n.attendanceRecordsEmpty;
  static String get recordCheckIn => appL10n.attendanceRecordCheckIn;
  static String get recordCheckOut => appL10n.attendanceRecordCheckOut;
  static String get recordGuardId => appL10n.attendanceRecordGuardId;
}
