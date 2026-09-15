import 'package:flutter/material.dart';

import '../../../../data/repositories/patient_repository.dart';
import '../../../../domain/models/patient.dart';

class PatientCreateViewModel extends ChangeNotifier {
  PatientCreateViewModel({required PatientRepository repository})
      : _repository = repository;

  final PatientRepository _repository;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  bool _loading = false;
  Patient? _created;

  bool get isLoading => _loading;
  Patient? get created => _created;

  Future<bool> create() async {
    final name = nameController.text.trim();
    final space = name.indexOf(' ');
    final firstName = space < 0 ? name : name.substring(0, space);
    final lastName = space < 0 ? '' : name.substring(space + 1).trim();

    _loading = true;
    _created = null;
    notifyListeners();
    final result = await _repository.create(
      firstName: firstName,
      lastName: lastName,
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
    );
    _loading = false;
    result.fold(
      ok: (patient) => _created = patient,
      err: (_) {},
    );
    notifyListeners();
    return result.isOk;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
