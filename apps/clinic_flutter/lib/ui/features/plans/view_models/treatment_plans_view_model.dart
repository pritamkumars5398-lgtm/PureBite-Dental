import 'package:flutter/material.dart';

import '../../../../data/repositories/treatment_plan_repository.dart';
import '../../../../domain/models/treatment_plan.dart';

class TreatmentPlansViewModel extends ChangeNotifier {
  TreatmentPlansViewModel({required TreatmentPlanRepository repository})
      : _repository = repository;

  final TreatmentPlanRepository _repository;
  List<TreatmentPlan> _plans = const [];
  bool _loading = false;
  String? _error;

  List<TreatmentPlan> get plans => _plans;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load({String? patientId, List<String>? status}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.list(
      patientId: patientId,
      status: status,
    );
    _loading = false;
    result.fold(
      ok: (list) => _plans = list,
      err: (e) => _error = e.toString(),
    );
    notifyListeners();
  }
}
