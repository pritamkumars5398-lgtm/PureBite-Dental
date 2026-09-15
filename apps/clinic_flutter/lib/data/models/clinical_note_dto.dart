import 'package:clinic_flutter/core/utils/json_utils.dart';
import 'package:clinic_flutter/domain/models/clinical_note.dart';

class ClinicalNoteDto {
  const ClinicalNoteDto({
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

  factory ClinicalNoteDto.fromJson(Map<String, dynamic> json) {
    final author = asMap(json['author']);
    return ClinicalNoteDto(
      id: asString(json['id']) ?? asString(json['note_id']) ?? '',
      clinicId: asString(json['clinic_id']) ?? '',
      noteType: asString(json['note_type']) ?? '',
      ownerType: asString(json['owner_type']) ?? '',
      ownerId: asString(json['owner_id']) ?? '',
      toothNumber: asInt(json['tooth_number']),
      body: asString(json['body']) ?? '',
      authorId: asString(json['author_id']) ?? asString(author?['id']) ?? '',
      authorName: asString(author?['full_name']),
      createdAt: asDateTime(json['created_at']) ?? DateTime.now().toUtc(),
      updatedAt: asDateTime(json['updated_at']) ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toCreateJson({
    List<String> attachmentDocumentIds = const [],
  }) {
    return {
      'note_type': noteType,
      'owner_type': ownerType,
      'owner_id': ownerId,
      'body': body,
      if (toothNumber != null) 'tooth_number': toothNumber,
      if (attachmentDocumentIds.isNotEmpty)
        'attachment_document_ids': attachmentDocumentIds,
    };
  }

  ClinicalNote toDomain() {
    return ClinicalNote(
      id: id,
      clinicId: clinicId,
      noteType: noteType,
      ownerType: ownerType,
      ownerId: ownerId,
      toothNumber: toothNumber,
      body: body,
      authorId: authorId,
      authorName: authorName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
