import 'package:clinic_flutter/data/models/auth_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses wrapped /auth/me payload', () {
    final dto = MeDto.fromResponse({
      'data': {
        'user': {
          'id': 'u1',
          'email': 'a@b.com',
          'first_name': 'Rajesh',
          'last_name': 'Kumar',
          'professional_id': null,
          'is_active': true,
        },
        'clinics': [
          {
            'id': 'c1',
            'name': 'Rajesh Clinics',
            'role': 'admin',
            'subscription_active': true,
            'subscription_end_date': '2026-10-13T10:30:23.787706+00:00',
          },
        ],
        'permissions': ['patients.read', 'patients.write'],
      },
    });

    expect(dto.user.email, 'a@b.com');
    expect(dto.clinics.single.name, 'Rajesh Clinics');
    expect(dto.permissions, ['patients.read', 'patients.write']);
  });
}
