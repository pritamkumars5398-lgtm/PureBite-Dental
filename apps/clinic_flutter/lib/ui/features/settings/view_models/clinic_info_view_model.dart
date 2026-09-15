import 'package:flutter/foundation.dart';

import '../../../../data/repositories/clinic_repository.dart';
import '../../../../domain/models/clinic.dart';

class ClinicInfoViewModel extends ChangeNotifier {
  ClinicInfoViewModel({required ClinicRepository repository})
      : _repository = repository;

  final ClinicRepository _repository;

  Clinic? _clinic;
  bool _loading = false;
  bool _saving = false;
  String? _error;

  Clinic? get clinic => _clinic;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;
  String get clinicName => _clinic?.name ?? '';

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.fetchCurrent();
    _loading = false;
    result.fold(
      ok: (clinic) => _clinic = clinic,
      err: (e) => _error = e.toString(),
    );
    notifyListeners();
  }

  Future<bool> save(ClinicUpdate data) async {
    _saving = true;
    _error = null;
    notifyListeners();
    final result = await _repository.update(data);
    _saving = false;
    return result.fold(
      ok: (clinic) {
        _clinic = clinic;
        notifyListeners();
        return true;
      },
      err: (e) {
        _error = e.toString();
        notifyListeners();
        return false;
      },
    );
  }
}
