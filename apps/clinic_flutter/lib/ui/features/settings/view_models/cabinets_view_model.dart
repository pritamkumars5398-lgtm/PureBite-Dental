import 'package:flutter/material.dart';

import '../../../../data/repositories/cabinet_repository.dart';
import '../../../../domain/models/cabinet.dart';

class CabinetsViewModel extends ChangeNotifier {
  CabinetsViewModel({required CabinetRepository repository})
    : _repository = repository;

  final CabinetRepository _repository;
  List<Cabinet> _cabinets = const [];
  bool _loading = false;
  String? _error;

  List<Cabinet> get cabinets => _cabinets;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.list();
    _loading = false;
    result.fold(
      ok: (list) => _cabinets = list,
      err: (e) => _error = e.toString(),
    );
    notifyListeners();
  }
}
