import '../../core/utils/json_utils.dart';
import '../../core/utils/string_utils.dart';
import '../../domain/models/appointment.dart';

class AppointmentDto {
  const AppointmentDto({
    required this.id,
    required this.clinicId,
    required this.professionalId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.updatedAt,
    this.patientId,
    this.treatmentType,
    this.patientName,
    this.cabinet,
    this.color,
  });

  final String id;
  final String clinicId;
  final String? patientId;
  final String professionalId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String? treatmentType;
  final String? patientName;
  final String? cabinet;
  final String? color;
  final DateTime updatedAt;

  factory AppointmentDto.fromJson(Map<String, dynamic> json) {
    return AppointmentDto(
      id: asString(json['id']) ?? '',
      clinicId: asString(json['clinic_id']) ?? '',
      patientId: asString(json['patient_id']),
      professionalId: asString(json['professional_id']) ?? '',
      startTime: asDateTime(json['start_time']) ?? DateTime.now().toUtc(),
      endTime: asDateTime(json['end_time']) ?? DateTime.now().toUtc(),
      status: asString(json['status']) ?? 'scheduled',
      treatmentType: asString(json['treatment_type']),
      patientName: _patientNameFromJson(json['patient']),
      cabinet: asString(json['cabinet']),
      color: asString(json['color']),
      updatedAt: asDateTime(json['updated_at']) ?? DateTime.now().toUtc(),
    );
  }

  Appointment toDomain() {
    return Appointment(
      id: id,
      clinicId: clinicId,
      patientId: patientId,
      professionalId: professionalId,
      startTime: startTime,
      endTime: endTime,
      status: status,
      treatmentType: treatmentType,
      patientName: patientName,
      cabinet: cabinet,
      color: color,
      updatedAt: updatedAt,
    );
  }

  static String? _patientNameFromJson(dynamic patient) {
    final map = asMap(patient);
    if (map == null) return null;
    final name = fullName(
      asString(map['first_name']) ?? '',
      asString(map['last_name']) ?? '',
    );
    return emptyToNull(name);
  }
}
