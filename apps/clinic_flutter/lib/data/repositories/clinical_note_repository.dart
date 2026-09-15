import 'package:clinic_flutter/core/constants/api_constants.dart';
import 'package:clinic_flutter/core/errors/app_exception.dart';
import 'package:clinic_flutter/core/utils/result.dart';
import 'package:clinic_flutter/data/models/clinical_note_dto.dart';
import 'package:clinic_flutter/data/services/api/api_client.dart';
import 'package:clinic_flutter/domain/models/clinical_note.dart';

class ClinicalNoteRepository {
  ClinicalNoteRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  List<ClinicalNote> _cache = const [];

  List<ClinicalNote> get cache => List.unmodifiable(_cache);

  Future<Result<List<ClinicalNote>>> listLocal() async => Ok(_cache);

  Future<Result<List<ClinicalNote>>> listForPatient(String patientId) async {
    try {
      final response = await _api.get(
        ApiConstants.clinicalNotes,
        query: {ApiConstants.queryPatientId: patientId},
      );
      final list = _parseList(response.data);
      _cache = list;
      return Ok(list);
    } on AppException catch (e) {
      if (_cache.isNotEmpty) return Ok(_cache);
      return Err(e);
    } catch (e) {
      if (_cache.isNotEmpty) return Ok(_cache);
      return Err(e);
    }
  }

  Future<Result<ClinicalNote>> create({
    required String patientId,
    required String body,
    String noteType = 'administrative',
    String ownerType = 'patient',
    String? ownerId,
    int? toothNumber,
    List<String> attachmentDocumentIds = const [],
  }) async {
    try {
      final payload = ClinicalNoteDto(
        id: '',
        clinicId: '',
        noteType: noteType,
        ownerType: ownerType,
        ownerId: ownerId ?? patientId,
        toothNumber: toothNumber,
        body: body,
        authorId: '',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ).toCreateJson(attachmentDocumentIds: attachmentDocumentIds);
      final response = await _api.post(
        ApiConstants.clinicalNotes,
        data: payload,
        query: {ApiConstants.queryPatientId: patientId},
      );
      final map = _unwrap(response.data);
      if (map == null) return const Err(AppException('Invalid note response'));
      final note = ClinicalNoteDto.fromJson(map).toDomain();
      _cache = [note, ..._cache.where((n) => n.id != note.id)];
      return Ok(note);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(e);
    }
  }

  Future<Result<void>> pullRemote({required String patientId}) async {
    final result = await listForPatient(patientId);
    return result.fold(ok: (_) => const Ok(null), err: Err.new);
  }

  List<ClinicalNote> _parseList(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => ClinicalNoteDto.fromJson(e).toDomain())
            .toList();
      }
    }
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map((e) => ClinicalNoteDto.fromJson(e).toDomain())
          .toList();
    }
    return const [];
  }

  Map<String, dynamic>? _unwrap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      if (raw.containsKey('id')) return raw;
    }
    return null;
  }
}
