class Appointment {
  const Appointment({
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
}
