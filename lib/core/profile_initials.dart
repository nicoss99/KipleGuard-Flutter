/// Mirrors Android `BaseActivity.getInitialName`.
String profileInitials(String? name) {
  if (name == null || name.isEmpty) return '';
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.contains(' ')) {
    final parts = trimmed.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.length >= 2) {
      final first = parts.first;
      final last = parts.last;
      return '${_firstCharUpper(first)}${_firstCharUpper(last)}';
    }
  }
  if (trimmed.length >= 2) {
    return trimmed.substring(0, 2).toUpperCase();
  }
  return trimmed.substring(0, 1).toUpperCase();
}

String _firstCharUpper(String s) {
  if (s.isEmpty) return '';
  return s.substring(0, 1).toUpperCase();
}
