import 'register_visitor_draft.dart';

/// Ports key rules from Android `GoogleTextRecognizer` (Mobile Vision) for ML Kit text.
bool registerOcrBlockedKeyword(String line) {
  final u = line.toUpperCase();
  const keys = [
    'DRIVING',
    'LICENCE',
    'LICENSE',
    'PENGENALAN',
    'LESEN',
    'MEMANDU',
    'IDENTITY',
    'CARD',
    'MYKAD',
    'MALAY',
    'KANAK',
    'NEGARA',
    'KAD',
    'NATIONALITY',
    'PEREMPUAN',
    'LELAKI',
  ];
  return keys.any(u.contains);
}

String registerOcrNormalizeToken(String s) => s.replaceAll(RegExp('[-/@]'), '').trim();

/// Extracts Malaysian IC-style 12-digit numbers from OCR text.
List<String> registerOcrFind12DigitIds(String raw) {
  final found = <String>{};
  final compact = raw.replaceAll(RegExp(r'[\s\-/]'), '');
  for (final m in RegExp(r'(?<!\d)\d{12}(?!\d)').allMatches(compact)) {
    found.add(m.group(0)!);
  }
  for (final line in raw.split('\n')) {
    final t = registerOcrNormalizeToken(line);
    if (RegExp(r'^[0-9]{12}$').hasMatch(t)) found.add(t);
  }
  return found.toList();
}

String? registerOcrFindNameLine(String raw) {
  for (final line in raw.split('\n')) {
    var s = line.trim();
    if (s.length < 10) continue;
    if (registerOcrBlockedKeyword(s)) continue;
    s = s.replaceAll('1', 'I');
    if (!RegExp(r'^[A-Z ]+$', caseSensitive: false).hasMatch(s)) continue;
    if (!s.contains(' ')) continue;
    return s;
  }
  return null;
}

/// MyKad: reject driving licence text; require 12-digit IC (Android `DocType.MYKAD`).
RegisterIdScanResult? registerOcrParseMyKad(String raw) {
  if (registerOcrBlockedKeyword(raw)) return null;
  final ids = registerOcrFind12DigitIds(raw);
  if (ids.isEmpty) return null;
  final ic = ids.first;
  final name = registerOcrFindNameLine(raw);
  return RegisterIdScanResult(ic12: ic, name: name);
}

/// Driving licence: reject MyKad-like headers; 12-digit + optional name (Android `DocType.LICENSE`).
RegisterIdScanResult? registerOcrParseLicense(String raw) {
  if (registerOcrBlockedKeyword(raw)) return null;
  final ids = registerOcrFind12DigitIds(raw);
  final ic = ids.isEmpty ? null : ids.first;
  final name = registerOcrFindNameLine(raw);
  if (ic == null && name == null) return null;
  return RegisterIdScanResult(ic12: ic, name: name);
}

/// "Others": tokenize for manual pick (Android `DocType.OTHERS` list UI).
List<String> registerOcrTokenizeOthers(String raw) {
  final out = <String>{};
  for (final line in raw.split('\n')) {
    for (final part in line.split(RegExp(r'\s+'))) {
      final t = part.trim();
      if (t.length < 2) continue;
      if (registerOcrBlockedKeyword(t)) continue;
      out.add(t);
    }
  }
  return out.toList();
}
