/// Short label for the dashboard site picker bar.
abstract final class DashboardHeaderTitle {
  static const defaultMaxLength = 24;

  static String format(String title, {int maxLength = defaultMaxLength}) {
    final t = title.trim();
    if (t.isEmpty || t.length <= maxLength) return t;
    return '${t.substring(0, maxLength - 1).trimRight()}…';
  }
}
