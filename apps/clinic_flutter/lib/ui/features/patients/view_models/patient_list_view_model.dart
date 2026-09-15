import 'package:flutter/material.dart';

import '../../../../data/repositories/patient_repository.dart';
import '../../../../domain/models/patient.dart';

class PatientListViewModel extends ChangeNotifier {
  PatientListViewModel({required PatientRepository repository})
      : _repository = repository;

  final PatientRepository _repository;
  List<Patient> _patients = const [];
  bool _loading = false;
  String? _error;

  List<Patient> get patients => _patients;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load({String? query}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.search(query: query);
    _loading = false;
    result.fold(
      ok: (list) => _patients = list,
      err: (e) => _error = e.toString(),
    );
    notifyListeners();
  }

  Future<void> search(String query) => load(query: query);
}
