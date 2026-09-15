class ClinicStaffUser {
  const ClinicStaffUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final String role;
  final DateTime createdAt;
}
