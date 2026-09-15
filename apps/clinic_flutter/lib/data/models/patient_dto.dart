import '../../domain/models/patient.dart';
import '../../core/utils/json_utils.dart';

class PatientDto {
  const PatientDto({
    required this.id,
    required this.clinicId,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.doNotContact,
    required this.updatedAt,
    this.patientNumber,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.notes,
  });

  final String id;
  final String clinicId;
  final String? patientNumber;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final DateTime? dateOfBirth;
  final String? notes;
  final String status;
  final bool doNotContact;
  final DateTime updatedAt;

  factory PatientDto.fromJson(Map<String, dynamic> json) {
    return PatientDto(
      id: asString(json['id']) ?? '',
      clinicId: asString(json['clinic_id']) ?? '',
      patientNumber: asString(json['patient_number']),
      firstName: asString(json['first_name']) ?? '',
      lastName: asString(json['last_name']) ?? '',
      phone: asString(json['phone']),
      email: asString(json['email']),
      dateOfBirth: asDateTime(json['date_of_birth']),
      notes: asString(json['notes']),
      status: asString(json['status']) ?? 'active',
      doNotContact: asBool(json['do_not_contact']),
      updatedAt: asDateTime(json['updated_at']) ?? DateTime.now().toUtc(),
    );
  }

  Patient toDomain() {
    return Patient(
      id: id,
      clinicId: clinicId,
      patientNumber: patientNumber,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      dateOfBirth: dateOfBirth,
      notes: notes,
      status: status,
      doNotContact: doNotContact,
      updatedAt: updatedAt,
    );
  }
}
