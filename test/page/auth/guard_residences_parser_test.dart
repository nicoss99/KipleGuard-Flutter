import 'package:flutter_test/flutter_test.dart';
import 'package:kiple_guard_flutter/page/auth/guard_residences_parser.dart';

void main() {
  test('parseGuardResidencesFromApi reads current_residence and residences', () {
    final result = parseGuardResidencesFromApi(<String, dynamic>{
      'current_residence': <String, dynamic>{
        'id': 58,
        'uuid': '1ba86211-7cd4-435e-907c-9691b1943bb5',
        'name': 'KL South@OKR',
        'address': 'B-21-8 VERVE SUITES KL SOUTH JLN KLANG LAMA',
        'city': 'Kuala Lumpur',
        'state': 'KUALA LUMPUR',
        'postcode': '50470',
        'image_url': 'https://example.com/cover.jpg',
        'role': 'security_guard',
      },
      'residences': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 456,
          'uuid': 'f39f02c9-adcc-417b-8f2c-1e4d01643c72',
          'name': 'Demo : Sales Ops',
          'address': 'Malaysia',
          'city': 'Taman Bahagia',
          'state': 'Kuala Lumpur',
          'postcode': '50470',
          'image_url': 'https://example.com/demo.jpg',
          'role': 'security_guard',
        },
        <String, dynamic>{
          'id': 58,
          'uuid': '1ba86211-7cd4-435e-907c-9691b1943bb5',
          'name': 'KL South@OKR',
          'address': 'B-21-8 VERVE SUITES KL SOUTH JLN KLANG LAMA',
          'city': 'Kuala Lumpur',
          'state': 'KUALA LUMPUR',
          'postcode': '50470',
          'image_url': 'https://example.com/cover.jpg',
          'role': 'security_guard',
        },
      ],
    });

    expect(result.currentResidence?.uuid, '1ba86211-7cd4-435e-907c-9691b1943bb5');
    expect(result.currentResidence?.name, 'KL South@OKR');
    expect(result.residences, hasLength(2));
    expect(result.residences.first.name, 'Demo : Sales Ops');
  });
}
