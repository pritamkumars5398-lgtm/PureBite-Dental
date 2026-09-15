import 'package:flutter/material.dart';

import '../../../../data/repositories/clinic_user_repository.dart';
import '../../../../domain/models/clinic_staff_user.dart';

class UsersViewModel extends ChangeNotifier {
  UsersViewModel({required ClinicUserRepository repository})
    : _repository = repository;

  final ClinicUserRepository _repository;
  List<ClinicStaffUser> _users = const [];
  bool _loading = false;
  String? _error;

  List<ClinicStaffUser> get users => _users;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.list();
    _loading = false;
    result.fold(ok: (list) => _users = list, err: (e) => _error = e.toString());
    notifyListeners();
  }
}
