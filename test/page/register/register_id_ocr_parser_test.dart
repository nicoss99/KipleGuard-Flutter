import 'package:flutter_test/flutter_test.dart';
import 'package:kiple_guard_flutter/page/register/register_id_ocr_parser.dart';

void main() {
  const licenseId = 'AA144300IND';
  const licenseIdAlt = 'AA111111AAA';
  const myKadId = '880202-08-1230';
  const myKadIdCompact = '880202081230';

  test('No. Pengenalan extracts AA144300IND', () {
    const raw = '''
No. Pengenalan
$licenseId
''';

    expect(registerOcrParseLicense(raw).result?.ic12, licenseId);
  });

  test('OCR misread IND suffix as 1ND fixes to AA144300IND', () {
    const raw = '''
No. Pengenalan
AA1443001ND
''';

    expect(registerOcrParseLicense(raw).result?.ic12, licenseId);
  });

  test('split AA144300 and IND joins to AA144300IND', () {
    const raw = '''
No. Pengenalan
AA144300
IND
''';

    expect(registerOcrParseLicense(raw).result?.ic12, licenseId);
  });

  test('single licence ID in OCR without label uses fallback', () {
    const raw = '''
LESEN MEMANDU
$licenseId
''';

    expect(registerOcrParseLicense(raw).result?.ic12, licenseId);
  });

  test('No. Pengenalan label extracts licence ID', () {
    const raw = '''
LESEN MEMANDU
No. Pengenalan
$licenseIdAlt
Tarikh Luput
09/09/2028
''';

    final outcome = registerOcrParseLicense(raw);

    expect(outcome.wrongDocumentType, isFalse);
    expect(outcome.result?.ic12, licenseIdAlt);
  });

  test('No. Pengenalan preferred over NRIC on No. K/P', () {
    const raw = '''
No. Pengenalan
$licenseIdAlt
No. K/P
900101-01-5677
''';

    expect(registerOcrParseLicense(raw).result?.ic12, licenseIdAlt);
  });

  test('stops before validity and does not pick date', () {
    const raw = '''
No. Pengenalan
$licenseIdAlt
Validity
09/09/2028
''';

    expect(registerOcrParseLicense(raw).result?.ic12, licenseIdAlt);
  });

  test('Identity No label extracts licence ID not NRIC', () {
    const raw = '''
Identity No.
$licenseIdAlt
No. K/P
900101-01-5677
''';

    expect(registerOcrParseLicense(raw).result?.ic12, licenseIdAlt);
  });

  test('No. Pengenalan on same line extracts licence ID', () {
    expect(registerOcrParseLicense('No. Pengenalan $licenseIdAlt').result?.ic12, licenseIdAlt);
  });

  test('registerOcrParseLicense handles OCR digit mistakes', () {
    const raw = '''
No. Pengenalan
AA11111IAAA
''';

    expect(registerOcrParseLicense(raw).result?.ic12, licenseIdAlt);
  });

  test('registerOcrParseLicense joins split licence ID lines', () {
    const raw = '''
No. Pengenalan
AA111111
AAA
''';

    expect(registerOcrParseLicense(raw).result?.ic12, licenseIdAlt);
  });

  test('registerOcrParseLicense rejects NRIC-only scan without licence ID', () {
    const raw = '''
No. K/P
900101-01-5677
Tarikh Luput
09/09/2028
''';

    expect(registerOcrParseLicense(raw).result, isNull);
  });

  test('registerOcrParseLicense rejects true MyKad scan on license tab', () {
    const myKadRaw = '''
KAD PENGENALAN MALAYSIA
MYKAD
$myKadId
''';

    expect(registerOcrParseLicense(myKadRaw).wrongDocumentType, isTrue);
  });

  test('registerOcrParseMyKad rejects driving licence document text', () {
    const licenseRaw = '''
LESEN MEMANDU
No. Pengenalan
$licenseIdAlt
''';

    expect(registerOcrParseMyKad(licenseRaw).wrongDocumentType, isTrue);
  });

  test('registerOcrParseMyKad extracts IC from MyKad OCR', () {
    const myKadRaw = '''
KAD PENGENALAN MALAYSIA
MYKAD
SITI BINTI HASSAN
$myKadId
''';

    expect(registerOcrParseMyKad(myKadRaw).result?.ic12, myKadIdCompact);
  });
}
