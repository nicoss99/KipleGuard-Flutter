import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @apiAttendanceLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load attendance'**
  String get apiAttendanceLoadFailed;

  /// No description provided for @apiIncidentReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Incident report failed'**
  String get apiIncidentReportFailed;

  /// No description provided for @apiIncidentTypesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load incident types'**
  String get apiIncidentTypesLoadFailed;

  /// No description provided for @apiInvalidAttendancePayload.
  ///
  /// In en, this message translates to:
  /// **'Invalid attendance payload'**
  String get apiInvalidAttendancePayload;

  /// No description provided for @apiInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username / password'**
  String get apiInvalidCredentials;

  /// No description provided for @apiInvalidLoginPayload.
  ///
  /// In en, this message translates to:
  /// **'Invalid login payload'**
  String get apiInvalidLoginPayload;

  /// No description provided for @apiLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get apiLoginFailed;

  /// No description provided for @apiLogoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get apiLogoutFailed;

  /// No description provided for @apiNetworkError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your Wi‑Fi or mobile data and try again.'**
  String get apiNetworkError;

  /// No description provided for @apiProfileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get apiProfileLoadFailed;

  /// No description provided for @apiRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get apiRequestFailed;

  /// No description provided for @apiResidencesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load residences'**
  String get apiResidencesLoadFailed;

  /// No description provided for @apiScanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed'**
  String get apiScanFailed;

  /// No description provided for @apiSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get apiSomethingWentWrong;

  /// No description provided for @apiVisitorDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load visitor'**
  String get apiVisitorDetailLoadFailed;

  /// No description provided for @apiVisitorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load visitors'**
  String get apiVisitorLoadFailed;

  /// No description provided for @apiVisitorTypesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load visitor types'**
  String get apiVisitorTypesLoadFailed;

  /// No description provided for @appTitleStaging.
  ///
  /// In en, this message translates to:
  /// **'KipleGuard (Staging)'**
  String get appTitleStaging;

  /// No description provided for @attendanceEndShiftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tamat'**
  String get attendanceEndShiftSubtitle;

  /// No description provided for @attendanceEndShiftTitle.
  ///
  /// In en, this message translates to:
  /// **'End Shift'**
  String get attendanceEndShiftTitle;

  /// No description provided for @attendanceMissingSecurityProfile.
  ///
  /// In en, this message translates to:
  /// **'Site security data is missing. Select a site again or contact support.'**
  String get attendanceMissingSecurityProfile;

  /// No description provided for @attendanceNoResidenceSelected.
  ///
  /// In en, this message translates to:
  /// **'No residence selected. Select a site from the dashboard first.'**
  String get attendanceNoResidenceSelected;

  /// No description provided for @attendanceRecordCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get attendanceRecordCheckIn;

  /// No description provided for @attendanceRecordCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Check out'**
  String get attendanceRecordCheckOut;

  /// No description provided for @attendanceRecordGuardId.
  ///
  /// In en, this message translates to:
  /// **'Guard ID'**
  String get attendanceRecordGuardId;

  /// No description provided for @attendanceRecordsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No attendance records for this day'**
  String get attendanceRecordsEmpty;

  /// No description provided for @attendanceShiftAlreadyEnded.
  ///
  /// In en, this message translates to:
  /// **'Shift already ended'**
  String get attendanceShiftAlreadyEnded;

  /// No description provided for @attendanceShiftAlreadyStarted.
  ///
  /// In en, this message translates to:
  /// **'Shift already started'**
  String get attendanceShiftAlreadyStarted;

  /// No description provided for @attendanceShiftEnded.
  ///
  /// In en, this message translates to:
  /// **'Shift ended'**
  String get attendanceShiftEnded;

  /// No description provided for @attendanceShiftEndedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your shift has ended successfully.'**
  String get attendanceShiftEndedMessage;

  /// No description provided for @attendanceShiftStarted.
  ///
  /// In en, this message translates to:
  /// **'Shift started'**
  String get attendanceShiftStarted;

  /// No description provided for @attendanceShiftStartedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your shift has started successfully.'**
  String get attendanceShiftStartedMessage;

  /// No description provided for @attendanceStartShiftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mula'**
  String get attendanceStartShiftSubtitle;

  /// No description provided for @attendanceStartShiftTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Shift'**
  String get attendanceStartShiftTitle;

  /// No description provided for @attendanceSuccessDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get attendanceSuccessDone;

  /// No description provided for @attendanceTabRecords.
  ///
  /// In en, this message translates to:
  /// **'Record List'**
  String get attendanceTabRecords;

  /// No description provided for @attendanceTabTaking.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendanceTabTaking;

  /// No description provided for @attendanceTitleRecords.
  ///
  /// In en, this message translates to:
  /// **'Record list'**
  String get attendanceTitleRecords;

  /// No description provided for @attendanceTitleTaking.
  ///
  /// In en, this message translates to:
  /// **'Taking attendance'**
  String get attendanceTitleTaking;

  /// No description provided for @bookingApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get bookingApply;

  /// No description provided for @bookingArrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get bookingArrival;

  /// No description provided for @bookingAttendees.
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get bookingAttendees;

  /// No description provided for @bookingAuthContact.
  ///
  /// In en, this message translates to:
  /// **'Authorised contact'**
  String get bookingAuthContact;

  /// No description provided for @bookingAuthIc.
  ///
  /// In en, this message translates to:
  /// **'Authorised IC'**
  String get bookingAuthIc;

  /// No description provided for @bookingAuthName.
  ///
  /// In en, this message translates to:
  /// **'Authorised person'**
  String get bookingAuthName;

  /// No description provided for @bookingBookingStatus.
  ///
  /// In en, this message translates to:
  /// **'Booking status'**
  String get bookingBookingStatus;

  /// No description provided for @bookingBookingType.
  ///
  /// In en, this message translates to:
  /// **'Booking type'**
  String get bookingBookingType;

  /// No description provided for @bookingCallGuest.
  ///
  /// In en, this message translates to:
  /// **'Call guest'**
  String get bookingCallGuest;

  /// No description provided for @bookingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get bookingCancel;

  /// No description provided for @bookingCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get bookingCategory;

  /// No description provided for @bookingCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get bookingCheckIn;

  /// No description provided for @bookingCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Check out'**
  String get bookingCheckOut;

  /// No description provided for @bookingChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get bookingChooseDate;

  /// No description provided for @bookingClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get bookingClear;

  /// No description provided for @bookingConfirmCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Start this booking now?'**
  String get bookingConfirmCheckIn;

  /// No description provided for @bookingConfirmCheckOut.
  ///
  /// In en, this message translates to:
  /// **'End this booking now?'**
  String get bookingConfirmCheckOut;

  /// No description provided for @bookingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get bookingDetailsTitle;

  /// No description provided for @bookingDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get bookingDuration;

  /// No description provided for @bookingEmptyAllBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings for this day.'**
  String get bookingEmptyAllBookings;

  /// No description provided for @bookingEmptyCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'No checked-in bookings for this day.'**
  String get bookingEmptyCheckedIn;

  /// No description provided for @bookingEmptyUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming bookings for this day.'**
  String get bookingEmptyUpcoming;

  /// No description provided for @bookingEmptyRefreshHint.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get bookingEmptyRefreshHint;

  /// No description provided for @bookingEndTime.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get bookingEndTime;

  /// No description provided for @bookingExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get bookingExit;

  /// No description provided for @bookingFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get bookingFilter;

  /// No description provided for @bookingFilterPickOne.
  ///
  /// In en, this message translates to:
  /// **'Choose a submitted date, category, or booking type to apply filters.'**
  String get bookingFilterPickOne;

  /// No description provided for @bookingGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get bookingGuest;

  /// No description provided for @bookingLastUpdatedToday.
  ///
  /// In en, this message translates to:
  /// **'Last updated today.'**
  String get bookingLastUpdatedToday;

  /// No description provided for @bookingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load bookings.'**
  String get bookingLoadFailed;

  /// No description provided for @bookingMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get bookingMobile;

  /// No description provided for @bookingNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get bookingNo;

  /// No description provided for @bookingNoBookingListed.
  ///
  /// In en, this message translates to:
  /// **'No booking listed.'**
  String get bookingNoBookingListed;

  /// No description provided for @bookingPastBookingChip.
  ///
  /// In en, this message translates to:
  /// **'Past booking'**
  String get bookingPastBookingChip;

  /// No description provided for @bookingPastBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Past booking'**
  String get bookingPastBookingTitle;

  /// No description provided for @bookingRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get bookingRoom;

  /// No description provided for @bookingSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get bookingSearchAction;

  /// No description provided for @bookingSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Guest or unit (min. 3 characters)'**
  String get bookingSearchHint;

  /// No description provided for @bookingSearchMinChars.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 3 characters to search.'**
  String get bookingSearchMinChars;

  /// No description provided for @bookingSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search bookings'**
  String get bookingSearchTitle;

  /// No description provided for @bookingSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No bookings found for \"{query}\".'**
  String bookingSearchNoResults(String query);

  /// No description provided for @bookingSearchScopeHint.
  ///
  /// In en, this message translates to:
  /// **'Searching all bookings on this day'**
  String get bookingSearchScopeHint;

  /// No description provided for @bookingStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get bookingStartTime;

  /// No description provided for @bookingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get bookingSubmitted;

  /// No description provided for @bookingSubmittedOn.
  ///
  /// In en, this message translates to:
  /// **'Booking submitted on'**
  String get bookingSubmittedOn;

  /// No description provided for @bookingTabAllBookings.
  ///
  /// In en, this message translates to:
  /// **'Booking(s)'**
  String get bookingTabAllBookings;

  /// No description provided for @bookingTabCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get bookingTabCheckedIn;

  /// No description provided for @bookingTabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get bookingTabUpcoming;

  /// No description provided for @bookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get bookingTitle;

  /// No description provided for @bookingToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get bookingToday;

  /// No description provided for @bookingUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get bookingUnit;

  /// No description provided for @bookingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Booking updated'**
  String get bookingUpdated;

  /// No description provided for @bookingCheckInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking checked in.'**
  String get bookingCheckInSuccess;

  /// No description provided for @bookingCheckOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking checked out.'**
  String get bookingCheckOutSuccess;

  /// No description provided for @bookingYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get bookingYes;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get commonSuccess;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @dashboardAppTitle.
  ///
  /// In en, this message translates to:
  /// **'KipleGuard'**
  String get dashboardAppTitle;

  /// No description provided for @dashboardAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get dashboardAttendance;

  /// No description provided for @dashboardBooking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get dashboardBooking;

  /// No description provided for @dashboardCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get dashboardCall;

  /// No description provided for @dashboardFeatureAttendance.
  ///
  /// In en, this message translates to:
  /// **'This feature enable members to log attendance'**
  String get dashboardFeatureAttendance;

  /// No description provided for @dashboardFeatureBooking.
  ///
  /// In en, this message translates to:
  /// **'This feature enable members to check booking'**
  String get dashboardFeatureBooking;

  /// No description provided for @dashboardFeatureCall.
  ///
  /// In en, this message translates to:
  /// **'This feature enable members to call the other members'**
  String get dashboardFeatureCall;

  /// No description provided for @dashboardFeatureReport.
  ///
  /// In en, this message translates to:
  /// **'This feature enable members to report incidents'**
  String get dashboardFeatureReport;

  /// No description provided for @dashboardFeatureVisitor.
  ///
  /// In en, this message translates to:
  /// **'This feature enable members to register visitors'**
  String get dashboardFeatureVisitor;

  /// No description provided for @dashboardKehadiran.
  ///
  /// In en, this message translates to:
  /// **'Kehadiran'**
  String get dashboardKehadiran;

  /// No description provided for @dashboardLaporan.
  ///
  /// In en, this message translates to:
  /// **'Laporan'**
  String get dashboardLaporan;

  /// No description provided for @dashboardNoRolesAuthorized.
  ///
  /// In en, this message translates to:
  /// **'User is not authorized as a security guard.'**
  String get dashboardNoRolesAuthorized;

  /// No description provided for @dashboardPelawat.
  ///
  /// In en, this message translates to:
  /// **'Pelawat'**
  String get dashboardPelawat;

  /// No description provided for @dashboardRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get dashboardRegister;

  /// No description provided for @dashboardReporting.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get dashboardReporting;

  /// No description provided for @dashboardScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get dashboardScanQr;

  /// No description provided for @dashboardTempahan.
  ///
  /// In en, this message translates to:
  /// **'Tempahan'**
  String get dashboardTempahan;

  /// No description provided for @dashboardViewQr.
  ///
  /// In en, this message translates to:
  /// **'View QR'**
  String get dashboardViewQr;

  /// No description provided for @dashboardVisitor.
  ///
  /// In en, this message translates to:
  /// **'Visitor'**
  String get dashboardVisitor;

  /// No description provided for @dashboardWelcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Guard'**
  String get dashboardWelcomeUser;

  /// No description provided for @listEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'There is nothing to show at the moment.'**
  String get listEmptyMessage;

  /// No description provided for @listEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get listEmptyTitle;

  /// No description provided for @loginEmailOrPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get loginEmailOrPhoneHint;

  /// No description provided for @loginEmailOrPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone Number'**
  String get loginEmailOrPhoneLabel;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username / password'**
  String get loginInvalidCredentials;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginRegionIndonesia.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get loginRegionIndonesia;

  /// No description provided for @loginRegionMalaysia.
  ///
  /// In en, this message translates to:
  /// **'Malaysia'**
  String get loginRegionMalaysia;

  /// No description provided for @loginRegionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select your region'**
  String get loginRegionPlaceholder;

  /// No description provided for @loginRegionSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose where your account is registered'**
  String get loginRegionSheetSubtitle;

  /// No description provided for @loginRegionSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Select your region'**
  String get loginRegionSheetTitle;

  /// No description provided for @loginRegionVietnam.
  ///
  /// In en, this message translates to:
  /// **'Vietnam'**
  String get loginRegionVietnam;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignIn;

  /// No description provided for @loginSignInFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get loginSignInFailedTitle;

  /// No description provided for @loginSwitchDeviceProceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get loginSwitchDeviceProceed;

  /// No description provided for @loginSwitchDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSwitchDeviceTitle;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get profileAccount;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// No description provided for @profileConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get profileConfirmPassword;

  /// No description provided for @profileConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm a new password'**
  String get profileConfirmPasswordHint;

  /// No description provided for @profileCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get profileCurrentPassword;

  /// No description provided for @profileCurrentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a current password'**
  String get profileCurrentPasswordHint;

  /// No description provided for @profileCurrentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get profileCurrentPasswordRequired;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileEmptyOfflineData.
  ///
  /// In en, this message translates to:
  /// **'No offline data'**
  String get profileEmptyOfflineData;

  /// No description provided for @profileForceLogout.
  ///
  /// In en, this message translates to:
  /// **'Force logout'**
  String get profileForceLogout;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'HELP & SUPPORT'**
  String get profileHelpSupport;

  /// No description provided for @profileMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get profileMobileNumber;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get profileNewPassword;

  /// No description provided for @profileNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get profileNewPasswordHint;

  /// No description provided for @profileOfflineData.
  ///
  /// In en, this message translates to:
  /// **'Offline Data'**
  String get profileOfflineData;

  /// No description provided for @offlineCachedSection.
  ///
  /// In en, this message translates to:
  /// **'Cached on this device'**
  String get offlineCachedSection;

  /// No description provided for @offlineNoPending.
  ///
  /// In en, this message translates to:
  /// **'No pending items to sync.'**
  String get offlineNoPending;

  /// No description provided for @offlinePendingIncidents.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 incident report waiting to sync} other{{count} incident reports waiting to sync}}'**
  String offlinePendingIncidents(int count);

  /// No description provided for @offlinePendingSection.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get offlinePendingSection;

  /// No description provided for @offlineSavedAt.
  ///
  /// In en, this message translates to:
  /// **'Saved {time}'**
  String offlineSavedAt(String time);

  /// No description provided for @offlineDataMessage.
  ///
  /// In en, this message translates to:
  /// **'You are offline.'**
  String get offlineDataMessage;

  /// No description provided for @offlineNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your Wi‑Fi or mobile data and try again.'**
  String get offlineNoConnection;

  /// No description provided for @offlineNoCachedData.
  ///
  /// In en, this message translates to:
  /// **'No internet connection and no saved data on this device. Connect to the internet to load.'**
  String get offlineNoCachedData;

  /// No description provided for @offlineShowingCached.
  ///
  /// In en, this message translates to:
  /// **'Showing saved data from {savedAt}'**
  String offlineShowingCached(String savedAt);

  /// No description provided for @offlineSyncDone.
  ///
  /// In en, this message translates to:
  /// **'Sync finished.'**
  String get offlineSyncDone;

  /// No description provided for @offlineSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get offlineSyncNow;

  /// No description provided for @profilePasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get profilePasswordEmpty;

  /// No description provided for @profilePasswordNotSame.
  ///
  /// In en, this message translates to:
  /// **'Password is not the same'**
  String get profilePasswordNotSame;

  /// No description provided for @profilePasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get profilePasswordUpdated;

  /// No description provided for @profileProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileProfileUpdated;

  /// No description provided for @profileResidences.
  ///
  /// In en, this message translates to:
  /// **'RESIDENCES'**
  String get profileResidences;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get profileSignOutConfirmationMessage;

  /// No description provided for @profileSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to logout'**
  String get profileSignOutFailed;

  /// No description provided for @profileWhatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new?'**
  String get profileWhatsNew;

  /// No description provided for @registerAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get registerAddPhoto;

  /// No description provided for @registerAddVisitorButton.
  ///
  /// In en, this message translates to:
  /// **'+ Add visitor'**
  String get registerAddVisitorButton;

  /// No description provided for @registerAddVisitorCta.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get registerAddVisitorCta;

  /// No description provided for @registerCarHint.
  ///
  /// In en, this message translates to:
  /// **'Eg : AHH123'**
  String get registerCarHint;

  /// No description provided for @registerCarPlateField.
  ///
  /// In en, this message translates to:
  /// **'Car plate'**
  String get registerCarPlateField;

  /// No description provided for @registerCarRecurringHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the car icon to check car plate for recurring visitors'**
  String get registerCarRecurringHint;

  /// No description provided for @registerChooseBuilding.
  ///
  /// In en, this message translates to:
  /// **'Choose building'**
  String get registerChooseBuilding;

  /// No description provided for @registerChooseOne.
  ///
  /// In en, this message translates to:
  /// **'Choose one'**
  String get registerChooseOne;

  /// No description provided for @registerCompanyField.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get registerCompanyField;

  /// No description provided for @registerCompanyHint.
  ///
  /// In en, this message translates to:
  /// **'Type in visitor\'s company'**
  String get registerCompanyHint;

  /// No description provided for @registerEmailField.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailField;

  /// No description provided for @registerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Type in visitor\'s email'**
  String get registerEmailHint;

  /// No description provided for @registerErrorRequired.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields'**
  String get registerErrorRequired;

  /// No description provided for @registerHostEmpty.
  ///
  /// In en, this message translates to:
  /// **'No host available for this unit'**
  String get registerHostEmpty;

  /// No description provided for @registerHostField.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get registerHostField;

  /// No description provided for @registerHostSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search host'**
  String get registerHostSearchHint;

  /// No description provided for @registerIcHint.
  ///
  /// In en, this message translates to:
  /// **'Eg : 872212052121'**
  String get registerIcHint;

  /// No description provided for @registerIcPassport.
  ///
  /// In en, this message translates to:
  /// **'IC/Passport'**
  String get registerIcPassport;

  /// No description provided for @registerMobileField.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get registerMobileField;

  /// No description provided for @registerMobileHint.
  ///
  /// In en, this message translates to:
  /// **'Type in visitor\'s mobile number'**
  String get registerMobileHint;

  /// No description provided for @registerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Type in visitor\'s name'**
  String get registerNameHint;

  /// No description provided for @registerPassIdField.
  ///
  /// In en, this message translates to:
  /// **'Pass ID'**
  String get registerPassIdField;

  /// No description provided for @registerPassIdHint.
  ///
  /// In en, this message translates to:
  /// **'Type in visitor\'s pass ID'**
  String get registerPassIdHint;

  /// No description provided for @registerPhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get registerPhotoCamera;

  /// No description provided for @registerPhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get registerPhotoGallery;

  /// No description provided for @registerPhotoMaxReached.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 5 photos.'**
  String get registerPhotoMaxReached;

  /// No description provided for @registerPhotoPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add up to 5 photos — use camera or gallery'**
  String get registerPhotoPickerSubtitle;

  /// No description provided for @registerPhotoPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Visitor photo'**
  String get registerPhotoPickerTitle;

  /// No description provided for @registerPhotoReplaceGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get registerPhotoReplaceGallery;

  /// No description provided for @registerPhotoRetakeCamera.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get registerPhotoRetakeCamera;

  /// No description provided for @registerPhotoSection.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get registerPhotoSection;

  /// No description provided for @registerScanAlignHint.
  ///
  /// In en, this message translates to:
  /// **'Align the card in the frame for a better result'**
  String get registerScanAlignHint;

  /// No description provided for @registerScanLightOff.
  ///
  /// In en, this message translates to:
  /// **'Light off'**
  String get registerScanLightOff;

  /// No description provided for @registerScanLightOn.
  ///
  /// In en, this message translates to:
  /// **'Light on'**
  String get registerScanLightOn;

  /// No description provided for @registerScanPickToken.
  ///
  /// In en, this message translates to:
  /// **'Pick a value from the scan'**
  String get registerScanPickToken;

  /// No description provided for @registerScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan ID'**
  String get registerScanTitle;

  /// No description provided for @registerSelectUnitFirst.
  ///
  /// In en, this message translates to:
  /// **'Select unit first'**
  String get registerSelectUnitFirst;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get registerSubmit;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Visitor registered'**
  String get registerSuccess;

  /// No description provided for @registerSuccessDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get registerSuccessDone;

  /// No description provided for @registerSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'The visitor has been added successfully.'**
  String get registerSuccessMessage;

  /// No description provided for @registerTempField.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get registerTempField;

  /// No description provided for @registerTempHint.
  ///
  /// In en, this message translates to:
  /// **'Type in visitor\'s temperature'**
  String get registerTempHint;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register visitor'**
  String get registerTitle;

  /// No description provided for @registerTypeNotAllowedToday.
  ///
  /// In en, this message translates to:
  /// **'This visit type is not allowed on the selected day.'**
  String get registerTypeNotAllowedToday;

  /// No description provided for @registerTypeOfVisit.
  ///
  /// In en, this message translates to:
  /// **'Type of visit'**
  String get registerTypeOfVisit;

  /// No description provided for @registerTypeResolveError.
  ///
  /// In en, this message translates to:
  /// **'This visit type is not available for this site. Sync visitor types or pick another.'**
  String get registerTypeResolveError;

  /// No description provided for @registerUnitEmpty.
  ///
  /// In en, this message translates to:
  /// **'No units available'**
  String get registerUnitEmpty;

  /// No description provided for @registerUnitField.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get registerUnitField;

  /// No description provided for @registerUnitSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search unit'**
  String get registerUnitSearchHint;

  /// No description provided for @registerVisitDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit details'**
  String get registerVisitDetailsTitle;

  /// No description provided for @registerVisitEnd.
  ///
  /// In en, this message translates to:
  /// **'Visit end'**
  String get registerVisitEnd;

  /// No description provided for @registerVisitEndHint.
  ///
  /// In en, this message translates to:
  /// **'End time is optional; policy may set a default from the visit type.'**
  String get registerVisitEndHint;

  /// No description provided for @registerVisitKindEmpty.
  ///
  /// In en, this message translates to:
  /// **'No visit types'**
  String get registerVisitKindEmpty;

  /// No description provided for @registerVisitStart.
  ///
  /// In en, this message translates to:
  /// **'Visit start'**
  String get registerVisitStart;

  /// No description provided for @registerVisitTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Choose visit type'**
  String get registerVisitTypeHint;

  /// No description provided for @registerVisitorDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Visitor details'**
  String get registerVisitorDetailsTitle;

  /// No description provided for @registerVisitorNameField.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get registerVisitorNameField;

  /// No description provided for @registerVisitorSection.
  ///
  /// In en, this message translates to:
  /// **'Visitor'**
  String get registerVisitorSection;

  /// No description provided for @reportingAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get reportingAddPhoto;

  /// No description provided for @reportingCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get reportingCamera;

  /// No description provided for @reportingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reportingCancel;

  /// No description provided for @reportingCheckingPin.
  ///
  /// In en, this message translates to:
  /// **'Checking your PIN in our system..'**
  String get reportingCheckingPin;

  /// No description provided for @reportingEnterMemberPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your member PIN'**
  String get reportingEnterMemberPin;

  /// No description provided for @reportingErrorBlank.
  ///
  /// In en, this message translates to:
  /// **'Please fill the blank'**
  String get reportingErrorBlank;

  /// No description provided for @reportingErrorReportDate.
  ///
  /// In en, this message translates to:
  /// **'You cannot choose future date to report an incident which never happened yet'**
  String get reportingErrorReportDate;

  /// No description provided for @reportingGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get reportingGallery;

  /// No description provided for @reportingImageLimit.
  ///
  /// In en, this message translates to:
  /// **'Image selection limit'**
  String get reportingImageLimit;

  /// No description provided for @reportingPhotoAttachedMany.
  ///
  /// In en, this message translates to:
  /// **'photos attached'**
  String get reportingPhotoAttachedMany;

  /// No description provided for @reportingPhotoAttachedOne.
  ///
  /// In en, this message translates to:
  /// **'photo attached'**
  String get reportingPhotoAttachedOne;

  /// No description provided for @reportingPhotoPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add up to 5 photos — use camera or gallery'**
  String get reportingPhotoPickerSubtitle;

  /// No description provided for @reportingPhotoPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Incident photo'**
  String get reportingPhotoPickerTitle;

  /// No description provided for @reportingPickerOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get reportingPickerOk;

  /// No description provided for @reportingPinNotFound.
  ///
  /// In en, this message translates to:
  /// **'This PIN doesn\'t exist in our system\nPlease check with your site supervisor'**
  String get reportingPinNotFound;

  /// No description provided for @reportingPinSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your PIN has been verified.'**
  String get reportingPinSuccessMessage;

  /// No description provided for @reportingReportAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get reportingReportAddPhoto;

  /// No description provided for @reportingReportDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get reportingReportDateTime;

  /// No description provided for @reportingReportDateTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the time/date/year'**
  String get reportingReportDateTimeHint;

  /// No description provided for @reportingReportDateTimeSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose when the incident happened'**
  String get reportingReportDateTimeSheetSubtitle;

  /// No description provided for @reportingReportDesc.
  ///
  /// In en, this message translates to:
  /// **'Describe the incident'**
  String get reportingReportDesc;

  /// No description provided for @reportingReportDetails.
  ///
  /// In en, this message translates to:
  /// **'Type in the details'**
  String get reportingReportDetails;

  /// No description provided for @reportingReportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report an Incident'**
  String get reportingReportIncident;

  /// No description provided for @reportingReportSaved.
  ///
  /// In en, this message translates to:
  /// **'Report successful saved'**
  String get reportingReportSaved;

  /// No description provided for @reportingReportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Incident'**
  String get reportingReportSubmit;

  /// No description provided for @reportingReportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your incident report has been sent successfully.'**
  String get reportingReportSuccessMessage;

  /// No description provided for @reportingReportSuccessQueued.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device and will sync when you are back online.'**
  String get reportingReportSuccessQueued;

  /// No description provided for @reportingReportSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Incident submitted'**
  String get reportingReportSuccessTitle;

  /// No description provided for @reportingReportType.
  ///
  /// In en, this message translates to:
  /// **'Incident type'**
  String get reportingReportType;

  /// No description provided for @reportingReportTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select incident type'**
  String get reportingReportTypeHint;

  /// No description provided for @reportingReportTypeSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the type of incident to report'**
  String get reportingReportTypeSheetSubtitle;

  /// No description provided for @reportingSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get reportingSubmit;

  /// No description provided for @reportingSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit. Please try again.'**
  String get reportingSubmitFailed;

  /// No description provided for @reportingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get reportingSuccess;

  /// No description provided for @reportingSuccessDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get reportingSuccessDone;

  /// No description provided for @reportingTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get reportingTryAgain;

  /// No description provided for @scanApplicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get scanApplicationTitle;

  /// No description provided for @scanNoQrInImage.
  ///
  /// In en, this message translates to:
  /// **'No QR code found in this image'**
  String get scanNoQrInImage;

  /// No description provided for @scanQrNotBelong.
  ///
  /// In en, this message translates to:
  /// **'QR does not belong to this residence'**
  String get scanQrNotBelong;

  /// No description provided for @scanQrNotBelong2.
  ///
  /// In en, this message translates to:
  /// **'QR does not belong to this building'**
  String get scanQrNotBelong2;

  /// No description provided for @scanScanAlignHint.
  ///
  /// In en, this message translates to:
  /// **'Align the QR code in the frame'**
  String get scanScanAlignHint;

  /// No description provided for @scanScanFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get scanScanFromGallery;

  /// No description provided for @scanScanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanScanQrCode;

  /// No description provided for @scanUnableScanQr.
  ///
  /// In en, this message translates to:
  /// **'Unable to scan QR code, recheck the details again'**
  String get scanUnableScanQr;

  /// No description provided for @selectSiteCurrentBadge.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get selectSiteCurrentBadge;

  /// No description provided for @selectSiteEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to any site yet.'**
  String get selectSiteEmptySubtitle;

  /// No description provided for @selectSiteEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No sites available'**
  String get selectSiteEmptyTitle;

  /// No description provided for @selectSitePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Site'**
  String get selectSitePageTitle;

  /// No description provided for @selectSiteRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get selectSiteRetry;

  /// No description provided for @selectSiteSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search site name'**
  String get selectSiteSearchHint;

  /// No description provided for @unitCallCallRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent calls'**
  String get unitCallCallRecentEmpty;

  /// No description provided for @unitCallCallRecentSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get unitCallCallRecentSearch;

  /// No description provided for @unitCallCannotLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Unable to open dialer'**
  String get unitCallCannotLaunchDialer;

  /// No description provided for @unitCallEmptyBlocks.
  ///
  /// In en, this message translates to:
  /// **'No blocks found'**
  String get unitCallEmptyBlocks;

  /// No description provided for @unitCallEmptyFloors.
  ///
  /// In en, this message translates to:
  /// **'No floors found'**
  String get unitCallEmptyFloors;

  /// No description provided for @unitCallEmptyHosts.
  ///
  /// In en, this message translates to:
  /// **'No hosts for this unit'**
  String get unitCallEmptyHosts;

  /// No description provided for @unitCallEmptyUnits.
  ///
  /// In en, this message translates to:
  /// **'No units found'**
  String get unitCallEmptyUnits;

  /// No description provided for @unitCallLoadingBlocks.
  ///
  /// In en, this message translates to:
  /// **'Loading blocks…'**
  String get unitCallLoadingBlocks;

  /// No description provided for @unitCallLoadingFloors.
  ///
  /// In en, this message translates to:
  /// **'Loading floors…'**
  String get unitCallLoadingFloors;

  /// No description provided for @unitCallLoadingHosts.
  ///
  /// In en, this message translates to:
  /// **'Loading hosts…'**
  String get unitCallLoadingHosts;

  /// No description provided for @unitCallLoadingUnits.
  ///
  /// In en, this message translates to:
  /// **'Loading units…'**
  String get unitCallLoadingUnits;

  /// No description provided for @unitCallMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get unitCallMember;

  /// No description provided for @unitCallNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone number for this unit'**
  String get unitCallNoPhone;

  /// No description provided for @unitCallNoResidence.
  ///
  /// In en, this message translates to:
  /// **'No site selected'**
  String get unitCallNoResidence;

  /// No description provided for @unitCallOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get unitCallOwner;

  /// No description provided for @unitCallPageTitleCall.
  ///
  /// In en, this message translates to:
  /// **'Call unit'**
  String get unitCallPageTitleCall;

  /// No description provided for @unitCallRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get unitCallRecent;

  /// No description provided for @unitCallRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get unitCallRetry;

  /// No description provided for @unitCallSearchBlockHint.
  ///
  /// In en, this message translates to:
  /// **'Search block'**
  String get unitCallSearchBlockHint;

  /// No description provided for @unitCallSearchFloorHint.
  ///
  /// In en, this message translates to:
  /// **'Search floor'**
  String get unitCallSearchFloorHint;

  /// No description provided for @unitCallSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search unit'**
  String get unitCallSearchHint;

  /// No description provided for @unitCallSearchNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching results'**
  String get unitCallSearchNoMatch;

  /// No description provided for @unitCallSelectBlock.
  ///
  /// In en, this message translates to:
  /// **'Select block'**
  String get unitCallSelectBlock;

  /// No description provided for @unitCallSelectFloor.
  ///
  /// In en, this message translates to:
  /// **'Select floor'**
  String get unitCallSelectFloor;

  /// No description provided for @unitCallSelectHost.
  ///
  /// In en, this message translates to:
  /// **'Select host'**
  String get unitCallSelectHost;

  /// No description provided for @unitCallTenant.
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get unitCallTenant;

  /// No description provided for @unitCallVoipComingSoon.
  ///
  /// In en, this message translates to:
  /// **'VoIP call — use the native app for masked calls (Twilio)'**
  String get unitCallVoipComingSoon;

  /// No description provided for @visitorCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get visitorCheckIn;

  /// No description provided for @visitorCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Check out'**
  String get visitorCheckOut;

  /// No description provided for @visitorDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Visitor details'**
  String get visitorDetailsTitle;

  /// No description provided for @visitorEmpty.
  ///
  /// In en, this message translates to:
  /// **'No visitors'**
  String get visitorEmpty;

  /// No description provided for @visitorLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load visitors'**
  String get visitorLoadError;

  /// No description provided for @visitorParkingLot.
  ///
  /// In en, this message translates to:
  /// **'Parking lot'**
  String get visitorParkingLot;

  /// No description provided for @visitorPelawat.
  ///
  /// In en, this message translates to:
  /// **'Pelawat'**
  String get visitorPelawat;

  /// No description provided for @visitorQrRequired.
  ///
  /// In en, this message translates to:
  /// **'QR code required for this action'**
  String get visitorQrRequired;

  /// No description provided for @visitorRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get visitorRegister;

  /// No description provided for @visitorSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get visitorSave;

  /// No description provided for @visitorSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, plate, pass, unit…'**
  String get visitorSearchHint;

  /// No description provided for @visitorTabCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get visitorTabCheckIn;

  /// No description provided for @visitorTabIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get visitorTabIncoming;

  /// No description provided for @visitorTabOvertime.
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get visitorTabOvertime;

  /// No description provided for @visitorTitle.
  ///
  /// In en, this message translates to:
  /// **'Visitor'**
  String get visitorTitle;

  /// No description provided for @visitorUpdated.
  ///
  /// In en, this message translates to:
  /// **'Visitor updated'**
  String get visitorUpdated;

  /// No description provided for @visitorCheckInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Visitor checked in.'**
  String get visitorCheckInSuccess;

  /// No description provided for @visitorCheckOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Visitor checked out.'**
  String get visitorCheckOutSuccess;

  /// No description provided for @visitorVisitorFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get visitorVisitorFrom;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
