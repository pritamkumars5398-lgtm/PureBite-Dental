import 'package:flutter/foundation.dart';

import '../../../../data/repositories/reports_repository.dart';
import '../../../../domain/models/aging_report.dart';

class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel({required ReportsRepository repository})
    : _repository = repository;

  final ReportsRepository _repository;
  AgingReport? _aging;
  bool _loading = false;

  AgingReport? get aging => _aging;
  bool get isLoading => _loading;

  String kpiValue(int index) {
    final buckets = _aging?.buckets;
    if (buckets == null || index < 0 || index >= buckets.length) return '0';
    final total = buckets[index].total.trim();
    return total.isEmpty ? '0' : total;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    final result = await _repository.aging();
    _aging = result.dataOrNull;
    _loading = false;
    notifyListeners();
  }
}
