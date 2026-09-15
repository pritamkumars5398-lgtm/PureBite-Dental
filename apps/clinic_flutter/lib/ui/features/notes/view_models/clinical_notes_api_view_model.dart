import 'package:flutter/material.dart';

import '../../../../data/repositories/clinical_note_repository.dart';
import '../../../../domain/models/clinical_note.dart';

class ClinicalNotesApiViewModel extends ChangeNotifier {
  ClinicalNotesApiViewModel({required ClinicalNoteRepository repository})
      : _repository = repository;

  final ClinicalNoteRepository _repository;
  final bodyController = TextEditingController();

  List<ClinicalNote> _notes = const [];
  bool _loading = false;
  String? _error;
  String? _patientId;

  List<ClinicalNote> get notes => _notes;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load({required String patientId}) async {
    _patientId = patientId;
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.listForPatient(patientId);
    _loading = false;
    result.fold(
      ok: (list) => _notes = list,
      err: (e) => _error = e.toString(),
    );
    notifyListeners();
  }

  Future<bool> create({
    String? patientId,
    String noteType = 'administrative',
    String ownerType = 'patient',
    String? ownerId,
    int? toothNumber,
  }) async {
    final id = patientId ?? _patientId;
    final text = bodyController.text.trim();
    if (id == null || text.isEmpty) return false;

    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.create(
      patientId: id,
      body: text,
      noteType: noteType,
      ownerType: ownerType,
      ownerId: ownerId,
      toothNumber: toothNumber,
    );
    _loading = false;
    final ok = result.isOk;
    result.fold(
      ok: (note) {
        _notes = [note, ..._notes.where((n) => n.id != note.id)];
        bodyController.clear();
      },
      err: (e) => _error = e.toString(),
    );
    notifyListeners();
    return ok;
  }

  @override
  void dispose() {
    bodyController.dispose();
    super.dispose();
  }
}
