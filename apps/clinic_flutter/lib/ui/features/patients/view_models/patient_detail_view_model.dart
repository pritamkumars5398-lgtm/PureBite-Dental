import 'package:flutter/material.dart';

import '../../../../data/repositories/patient_repository.dart';
import '../../../../domain/models/patient.dart';

class PatientDetailViewModel extends ChangeNotifier {
  PatientDetailViewModel({required PatientRepository repository})
      : _repository = repository;

  final PatientRepository _repository;
  Patient? _patient;
  bool _loading = false;

  Patient? get patient => _patient;
  bool get isLoading => _loading;

  Future<void> load(String id) async {
    _loading = true;
    notifyListeners();
    final result = await _repository.getById(id);
    _patient = result.dataOrNull;
    _loading = false;
    notifyListeners();
  }
}
