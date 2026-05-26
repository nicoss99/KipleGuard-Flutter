import '../../l10n/app_l10n.dart';

/// Localized via [appL10n] — keys in `lib/l10n/app_en.arb`.
abstract final class SelectSiteStrings {
  static String get pageTitle => appL10n.selectSitePageTitle;
  static String get searchHint => appL10n.selectSiteSearchHint;
  static String get currentBadge => appL10n.selectSiteCurrentBadge;
  static String get emptyTitle => appL10n.selectSiteEmptyTitle;
  static String get emptySubtitle => appL10n.selectSiteEmptySubtitle;
  static String get retry => appL10n.selectSiteRetry;
}
