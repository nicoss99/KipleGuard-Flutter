import 'register_visitor_draft.dart';

/// Result of parsing OCR text for a selected document tab.
class RegisterIdOcrOutcome {
  const RegisterIdOcrOutcome._({
    this.result,
    this.wrongDocumentType = false,
  });

  final RegisterIdScanResult? result;
  final bool wrongDocumentType;

  factory RegisterIdOcrOutcome.success(RegisterIdScanResult result) =>
      RegisterIdOcrOutcome._(result: result);

  factory RegisterIdOcrOutcome.wrongDocumentType() =>
      const RegisterIdOcrOutcome._(wrongDocumentType: true);

  factory RegisterIdOcrOutcome.noMatch() => const RegisterIdOcrOutcome._();
}

/// Header words on a driving licence — reject on MyKad tab only.
bool registerOcrLooksLikeLicenseDoc(String text) {
  final u = text.toUpperCase();
  const keys = ['DRIVING', 'LICENCE', 'LICENSE', 'LESEN', 'MEMANDU'];
  return keys.any(u.contains);
}

/// MyKad-only headers. Do not treat licence "No. Pengenalan" as MyKad.
bool registerOcrLooksLikeMyKadDoc(String text) {
  final u = text.toUpperCase();
  if (u.contains('MYKAD')) return true;
  if (u.contains('KAD PENGENALAN')) return true;
  if (u.contains('PENGENALAN MALAYSIA')) return true;
  return false;
}

bool registerOcrLineLooksLikePengenalanLabel(String line) {
  if (RegExp(r'no\.?\s*pengenalan', caseSensitive: false).hasMatch(line)) {
    return true;
  }
  final compact = line.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  return compact.contains('NOPENGENALAN') ||
      (compact.contains('NOMBOR') && compact.contains('PENGENALAN'));
}

bool registerOcrLineLooksLikeIdentityNoLabel(String line) {
  final compact = line.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  if (compact.contains('IDENTIFICATIONNO') ||
      compact.contains('IDENTIFYNO') ||
      compact.contains('IDENTITYNO')) {
    return true;
  }
  return compact.contains('IDENTIF') && compact.contains('NO');
}

bool registerOcrLineLooksLikeNricLabel(String line) {
  final u = line.toUpperCase();
  final compact = u.replaceAll(RegExp(r'[^A-Z0-9/]'), '');
  return u.contains('K/P') ||
      u.contains('K.P') ||
      compact.contains('NOKP') ||
      compact.contains('NOMBORKP') ||
      compact.contains('NO/KP');
}

bool registerOcrLineLooksLikeValidityLabel(String line) {
  final u = line.toUpperCase();
  const keys = [
    'VALIDITY',
    'VALID',
    'EXPIR',
    'TARIKH LUPUT',
    'TEMPOH',
    'SAHLAKU',
    'LUPUT',
    'BERKUATKUASA',
    'MASA SAHLAKU',
  ];
  return keys.any(u.contains);
}

bool registerOcrLineLooksLikeDateOnly(String line) {
  final t = line.trim();
  if (RegExp(r'^\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4}$').hasMatch(t)) return true;
  final digits = t.replaceAll(RegExp(r'\D'), '');
  return digits.length == 8 && RegExp(r'^\d{8}$').hasMatch(digits);
}

bool registerOcrLineShouldStopLicenseIdSearch(String line) {
  return registerOcrLineLooksLikeValidityLabel(line) ||
      registerOcrLineLooksLikeNricLabel(line) ||
      registerOcrLineLooksLikeDateOnly(line);
}

bool registerOcrBlockedNameLineKeyword(String line) {
  final u = line.toUpperCase();
  const keys = [
    'DRIVING',
    'LICENCE',
    'LICENSE',
    'LESEN',
    'MEMANDU',
    'PENGENALAN',
    'IDENTITY',
    'IDENTIFICATION',
    'MYKAD',
    'MALAYSIA',
    'MALAY',
    'NEGARA',
    'NATIONALITY',
    'PEREMPUAN',
    'LELAKI',
    'WARGANEGARA',
    'TEMPAT',
    'LAHIR',
    'TARIKH',
    'ALAMAT',
    'NO.',
    'K/P',
  ];
  return keys.any(u.contains);
}

bool registerOcrBlockedKeyword(String line) => registerOcrBlockedNameLineKeyword(line);

String registerOcrNormalizeToken(String s) => s.replaceAll(RegExp('[-/@]'), '').trim();

String registerOcrNormalizeOcrDigits(String raw) =>
    raw.replaceAll(RegExp(r'[Oo]'), '0').replaceAll(RegExp(r'[Il|]'), '1');

String registerOcrNormalizeIdDigits(String raw) =>
    registerOcrNormalizeOcrDigits(raw).replaceAll('B', '8').replaceAll('b', '8');

String registerOcrCompactLicenseId(String raw) =>
    raw.replaceAll(RegExp(r'[\s\-./]'), '').toUpperCase();

/// Malaysian licence ID e.g. AA144300IND, AA111111AAA (2 letters + digits + 2–4 letters).
bool registerOcrLooksLikeStrictLicenseId(String raw) {
  final s = registerOcrCompactLicenseId(raw);
  return RegExp(r'^[A-Z]{2}\d{5,8}[A-Z]{2,4}$').hasMatch(s);
}

String registerOcrFixLicenseIdLetters(String letters) {
  return letters
      .replaceAll('0', 'O')
      .replaceAll('1', 'I')
      .replaceAll('8', 'B')
      .replaceAll('|', 'I')
      .replaceAll('l', 'I');
}

String? registerOcrFixAndValidateLicenseId(String compact) {
  final attempts = [
    RegExp(r'^([A-Z]{2})(\d{6})([A-Z0-9]{2,4})$'),
    RegExp(r'^([A-Z]{2})([0-9I]{6})([A-Z]{2,4})$'),
    RegExp(r'^([A-Z]{2})(\d{5,8})([A-Z0-9]{2,4})$'),
  ];

  for (final pattern in attempts) {
    final match = pattern.firstMatch(compact);
    if (match == null) continue;

    final prefix = registerOcrFixLicenseIdLetters(match.group(1)!);
    final middle = match.group(2)!.replaceAll('O', '0').replaceAll('I', '1').replaceAll('B', '8');
    final suffix = registerOcrFixLicenseIdLetters(match.group(3)!);
    final fixed = '$prefix$middle$suffix';
    if (registerOcrLooksLikeStrictLicenseId(fixed)) return fixed;
  }

  return null;
}

String registerOcrFixLicenseIdOcr(String compact) {
  return registerOcrFixAndValidateLicenseId(compact) ?? compact;
}

String? registerOcrExtractStrictLicenseId(String line) {
  final compact = registerOcrCompactLicenseId(line);
  final patterns = [
    RegExp(r'[A-Z]{2}\d{6}[A-Z0-9]{2,4}'),
    RegExp(r'[A-Z]{2}[0-9I]{6}[A-Z]{2,4}'),
    RegExp(r'[A-Z]{2}\d{5,8}[A-Z0-9]{2,4}'),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(compact);
    if (match == null) continue;
    final fixed = registerOcrFixAndValidateLicenseId(match.group(0)!);
    if (fixed != null) return fixed;
  }

  return null;
}

List<String> registerOcrFindAllStrictLicenseIds(String raw) {
  final found = <String>{};
  for (final line in raw.split('\n')) {
    final id = registerOcrExtractStrictLicenseId(line);
    if (id != null) found.add(id);
    final stripped = registerOcrStripLicenseIdentificationLabel(line);
    if (stripped != line.trim()) {
      final onStripped = registerOcrExtractStrictLicenseId(stripped);
      if (onStripped != null) found.add(onStripped);
    }
  }

  final compactLines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
  for (var i = 0; i < compactLines.length - 1; i++) {
    final joined = registerOcrExtractStrictLicenseId('${compactLines[i]} ${compactLines[i + 1]}');
    if (joined != null) found.add(joined);
  }

  return found.toList();
}

String registerOcrStripLicenseIdentificationLabel(String line) {
  var s = line;
  const patterns = [
    r'identification\s*no\.?',
    r'identify\s*no\.?',
    r'identity\s*no\.?',
    r'no\.?\s*pengenalan',
    r'nombor\s*pengenalan',
  ];
  for (final pattern in patterns) {
    s = s.replaceAll(RegExp(pattern, caseSensitive: false), ' ');
  }
  return s.trim();
}

String? registerOcrReadLicenseIdNearLabel(List<String> lines, int labelIndex) {
  final sameLine = registerOcrExtractStrictLicenseId(
    registerOcrStripLicenseIdentificationLabel(lines[labelIndex]),
  );
  if (sameLine != null) return sameLine;

  if (labelIndex > 0 && !registerOcrLineLooksLikePengenalanLabel(lines[labelIndex - 1]) &&
      !registerOcrLineLooksLikeIdentityNoLabel(lines[labelIndex - 1])) {
    final above = registerOcrExtractStrictLicenseId(lines[labelIndex - 1]);
    if (above != null) return above;
  }

  for (var j = labelIndex + 1; j <= labelIndex + 3 && j < lines.length; j++) {
    if (registerOcrLineShouldStopLicenseIdSearch(lines[j])) break;

    final onLine = registerOcrExtractStrictLicenseId(lines[j]);
    if (onLine != null) return onLine;

    if (j + 1 < lines.length && !registerOcrLineShouldStopLicenseIdSearch(lines[j + 1])) {
      final joined = registerOcrExtractStrictLicenseId('${lines[j]} ${lines[j + 1]}');
      if (joined != null) return joined;
    }
  }

  return null;
}

/// Licence: read AA144300IND beside No. Pengenalan / Identity No. labels.
String? registerOcrFindLicenseIdentificationNo(String raw) {
  final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  for (var i = 0; i < lines.length; i++) {
    if (!registerOcrLineLooksLikePengenalanLabel(lines[i])) continue;
    final id = registerOcrReadLicenseIdNearLabel(lines, i);
    if (id != null) return id;
  }

  for (var i = 0; i < lines.length; i++) {
    if (!registerOcrLineLooksLikeIdentityNoLabel(lines[i])) continue;
    final id = registerOcrReadLicenseIdNearLabel(lines, i);
    if (id != null) return id;
  }

  final all = registerOcrFindAllStrictLicenseIds(raw);
  if (all.length == 1) return all.first;

  return null;
}

bool registerOcrIsValidMalaysianIc(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 12 || !RegExp(r'^\d{12}$').hasMatch(digits)) return false;
  const weights = [2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
  var sum = 0;
  for (var i = 0; i < 11; i++) {
    sum += int.parse(digits[i]) * weights[i];
  }
  final check = (10 - (sum % 10)) % 10;
  return check == int.parse(digits[11]);
}

String? registerOcrPickNricCandidate(Iterable<String> candidates) {
  final list = candidates.toList();
  if (list.isEmpty) return null;

  for (final c in list) {
    if (registerOcrIsValidMalaysianIc(c)) return c;
  }
  if (list.length == 1) return list.first;
  return null;
}

List<String> registerOcrFind12DigitIds(String raw) {
  final found = <String>{};
  final normalized = registerOcrNormalizeOcrDigits(raw);

  for (final m in RegExp(r'(\d{6})[\s\-./]*(\d{2})[\s\-./]*(\d{4})').allMatches(normalized)) {
    found.add('${m.group(1)}${m.group(2)}${m.group(3)}');
  }

  final compact = normalized.replaceAll(RegExp(r'[\s\-/]'), '');
  for (final m in RegExp(r'(?<!\d)\d{12}(?!\d)').allMatches(compact)) {
    found.add(m.group(0)!);
  }

  for (final line in normalized.split('\n')) {
    final t = registerOcrNormalizeToken(line);
    if (RegExp(r'^[0-9]{12}$').hasMatch(t)) found.add(t);
    final digitsOnly = t.replaceAll(RegExp(r'\D'), '');
    if (RegExp(r'^\d{12}$').hasMatch(digitsOnly)) found.add(digitsOnly);
  }

  return found.toList();
}

String? registerOcrFindNameLine(String raw) {
  for (final line in raw.split('\n')) {
    var s = line.trim();
    if (s.length < 10) continue;
    if (registerOcrBlockedNameLineKeyword(s)) continue;
    s = s.replaceAll('1', 'I');
    if (!RegExp(r'^[A-Z ]+$', caseSensitive: false).hasMatch(s)) continue;
    if (!s.contains(' ')) continue;
    return s;
  }
  return null;
}

RegisterIdOcrOutcome registerOcrParseMyKad(String raw) {
  if (registerOcrLooksLikeLicenseDoc(raw)) {
    return RegisterIdOcrOutcome.wrongDocumentType();
  }
  final ids = registerOcrFind12DigitIds(raw);
  if (ids.isEmpty) return RegisterIdOcrOutcome.noMatch();
  final ic = registerOcrPickNricCandidate(ids) ?? ids.first;
  final name = registerOcrFindNameLine(raw);
  return RegisterIdOcrOutcome.success(RegisterIdScanResult(ic12: ic, name: name));
}

RegisterIdOcrOutcome registerOcrParseLicense(String raw) {
  if (registerOcrLooksLikeMyKadDoc(raw) && !registerOcrLooksLikeLicenseDoc(raw)) {
    return RegisterIdOcrOutcome.wrongDocumentType();
  }

  final id = registerOcrFindLicenseIdentificationNo(raw);
  if (id == null) return RegisterIdOcrOutcome.noMatch();
  final name = registerOcrFindNameLine(raw);
  return RegisterIdOcrOutcome.success(RegisterIdScanResult(ic12: id, name: name));
}

List<String> registerOcrTokenizeOthers(String raw) {
  final out = <String>{};
  for (final line in raw.split('\n')) {
    for (final part in line.split(RegExp(r'\s+'))) {
      final t = part.trim();
      if (t.length < 2) continue;
      if (registerOcrBlockedNameLineKeyword(t)) continue;
      out.add(t);
    }
  }
  return out.toList();
}
