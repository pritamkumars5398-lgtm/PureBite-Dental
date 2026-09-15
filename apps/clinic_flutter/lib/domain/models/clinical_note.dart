class ClinicalNote {
  const ClinicalNote({
    required this.id,
    required this.clinicId,
    required this.noteType,
    required this.ownerType,
    required this.ownerId,
    required this.body,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    this.toothNumber,
    this.authorName,
  });

  final String id;
  final String clinicId;
  final String noteType;
  final String ownerType;
  final String ownerId;
  final int? toothNumber;
  final String body;
  final String authorId;
  final String? authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
}
