import 'package:flutter/foundation.dart';

import '../../../../data/repositories/odontogram_repository.dart';

enum OdontogramCellState { intact, planned, done }

class OdontogramViewModel extends ChangeNotifier {
  OdontogramViewModel({required OdontogramRepository repository})
      : _repository = repository;

  final OdontogramRepository _repository;

  Odontogram? _odontogram;
  bool _loading = false;
  Object? _error;

  Odontogram? get odontogram => _odontogram;
  bool get isLoading => _loading;
  Object? get error => _error;
  bool get hasData => _odontogram?.hasRecords ?? false;

  OdontogramCellState cellState(int toothNumber) {
    final odontogram = _odontogram;
    if (odontogram == null) return OdontogramCellState.intact;

    var planned = false;
    var done = false;
    for (final treatment in odontogram.treatments) {
      if (!treatment.toothNumbers.contains(toothNumber)) continue;
      final status = treatment.status.toLowerCase();
      if (status == 'planned') {
        planned = true;
      } else if (status == 'performed' ||
          status == 'existing' ||
          status == 'done') {
        done = true;
      }
    }

    if (planned) return OdontogramCellState.planned;
    if (done) return OdontogramCellState.done;

    OdontogramTooth? tooth;
    for (final candidate in odontogram.teeth) {
      if (candidate.number == toothNumber) {
        tooth = candidate;
        break;
      }
    }
    if (tooth == null) return OdontogramCellState.intact;

    if (_isActiveCondition(tooth.generalCondition)) {
      return OdontogramCellState.done;
    }
    for (final condition in tooth.surfaces.values) {
      if (_isActiveCondition(condition)) return OdontogramCellState.done;
    }
    return OdontogramCellState.intact;
  }

  Future<void> load(String patientId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.getForPatient(patientId);
    _odontogram = result.dataOrNull;
    _error = result.fold(ok: (_) => null, err: (error) => error);
    _loading = false;
    notifyListeners();
  }

  bool _isActiveCondition(String condition) {
    final value = condition.toLowerCase();
    return value.isNotEmpty && value != 'healthy';
  }
}
