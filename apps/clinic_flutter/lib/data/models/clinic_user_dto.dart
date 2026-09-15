import '../../core/utils/json_utils.dart';
import '../../domain/models/clinic_staff_user.dart';

class ClinicUserDto {
  const ClinicUserDto({
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

  factory ClinicUserDto.fromJson(Map<String, dynamic> json) {
    return ClinicUserDto(
      id: asString(json['id']) ?? '',
      email: asString(json['email']) ?? '',
      firstName: asString(json['first_name']) ?? '',
      lastName: asString(json['last_name']) ?? '',
      isActive: asBool(json['is_active'], fallback: true),
      role: asString(json['role']) ?? '',
      createdAt: asDateTime(json['created_at']) ?? DateTime.now().toUtc(),
    );
  }

  ClinicStaffUser toDomain() {
    return ClinicStaffUser(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      isActive: isActive,
      role: role,
      createdAt: createdAt,
    );
  }
}
