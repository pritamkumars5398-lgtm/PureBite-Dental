import 'package:clinic_flutter/core/constants/api_constants.dart';
import 'package:clinic_flutter/core/constants/app_breakpoints.dart';
import 'package:clinic_flutter/core/constants/app_icons.dart';
import 'package:clinic_flutter/core/constants/app_spacing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('spacing and icon tokens stay on the 4px scale', () {
    expect(AppSpacing.md, 16);
    expect(AppSpacing.tapTarget, 44);
    expect(AppIcons.lg, 24);
    expect(AppIcons.nav, 20);
    expect(AppIcons.lucide, 20);
    expect(AppBreakpoints.compact, 600);
  });

  test('API paths are versioned once', () {
    expect(ApiConstants.login, '/api/v1/auth/login');
    expect(ApiConstants.patients, '/api/v1/patients');
    expect(ApiConstants.appointments, '/api/v1/agenda/appointments');
    expect(ApiConstants.patient('abc'), '/api/v1/patients/abc');
    expect(ApiConstants.vatTypes, '/api/v1/catalog/vat-types');
  });
}
