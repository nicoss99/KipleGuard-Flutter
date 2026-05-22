/// Title-case helper for app bar labels (first letter of each word capitalized).
abstract final class AppBarTitleFormat {
  static String format(String title) {
    final t = title.trim();
    if (t.isEmpty) return t;

    return t.split(RegExp(r'\s+')).map(_capitalizeWord).join(' ');
  }

  static String _capitalizeWord(String word) {
    if (word.isEmpty) return word;
    if (_preserveCasing(word)) return word;

    final lower = word.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  /// Keeps acronyms (QR), brands (kipleSafe), and already title-cased tokens.
  static bool _preserveCasing(String word) {
    if (word.length <= 4 && word == word.toUpperCase()) return true;
    if (RegExp(r'^[A-Z][a-z]').hasMatch(word)) return true;
    if (RegExp(r'^[A-Z]{2,}$').hasMatch(word)) return true;
    return false;
  }
}
