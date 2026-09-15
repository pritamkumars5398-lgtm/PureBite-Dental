import 'clinic.dart';
import 'user.dart';

export 'clinic.dart';
export 'user.dart';

class Session {
  const Session({
    required this.user,
    required this.clinics,
    required this.permissions,
    required this.selectedClinicId,
  });

  final User user;
  final List<ClinicMembership> clinics;
  final List<String> permissions;
  final String selectedClinicId;

  bool can(String permission) {
    if (permissions.contains('*') || permissions.contains(permission)) {
      return true;
    }
    final parts = permission.split('.');
    if (parts.length >= 2 && permissions.contains('${parts.first}.*')) {
      return true;
    }
    return false;
  }
}
