class Patient {
  const Patient({
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

  String get displayName => '$firstName $lastName'.trim();
  bool get isArchived => status == 'archived';
}
