/// Malaysia (MYT) wall-clock helpers for guard attendance display.
abstract final class GuardTimezone {
  /// Naive datetime components — MYT wall clock from API string.
  static DateTime wallClock(int year, int month, int day, int hour, int minute, int second) =>
      DateTime(year, month, day, hour, minute, second);
}
