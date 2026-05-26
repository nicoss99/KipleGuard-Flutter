import '../../l10n/app_l10n.dart';

/// Localized via [appL10n] — keys in `lib/l10n/app_en.arb`.
abstract final class UnitCallStrings {
  static String get pageTitleCall => appL10n.unitCallPageTitleCall;
  static String get selectBlock => appL10n.unitCallSelectBlock;
  static String get selectHost => appL10n.unitCallSelectHost;
  static String get selectFloor => appL10n.unitCallSelectFloor;
  static String get recent => appL10n.unitCallRecent;
  static String get callRecentSearch => appL10n.unitCallCallRecentSearch;
  static String get callRecentEmpty => appL10n.unitCallCallRecentEmpty;
  static String get searchHint => appL10n.unitCallSearchHint;
  static String get searchBlockHint => appL10n.unitCallSearchBlockHint;
  static String get searchFloorHint => appL10n.unitCallSearchFloorHint;
  static String get searchNoMatch => appL10n.unitCallSearchNoMatch;
  static String get owner => appL10n.unitCallOwner;
  static String get tenant => appL10n.unitCallTenant;
  static String get member => appL10n.unitCallMember;
  static String get retry => appL10n.unitCallRetry;
  static String get noResidence => appL10n.unitCallNoResidence;
  static String get noPhone => appL10n.unitCallNoPhone;
  static String get cannotLaunchDialer => appL10n.unitCallCannotLaunchDialer;
  static String get voipComingSoon => appL10n.unitCallVoipComingSoon;
  static String get loadingUnits => appL10n.unitCallLoadingUnits;
  static String get loadingBlocks => appL10n.unitCallLoadingBlocks;
  static String get loadingFloors => appL10n.unitCallLoadingFloors;
  static String get loadingHosts => appL10n.unitCallLoadingHosts;
  static String get emptyHosts => appL10n.unitCallEmptyHosts;
  static String get emptyBlocks => appL10n.unitCallEmptyBlocks;
  static String get emptyFloors => appL10n.unitCallEmptyFloors;
  static String get emptyUnits => appL10n.unitCallEmptyUnits;
}
