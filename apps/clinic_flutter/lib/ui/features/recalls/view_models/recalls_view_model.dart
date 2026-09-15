import 'package:flutter/material.dart';

import '../../../../data/repositories/recall_repository.dart';
import '../../../../domain/models/recall.dart';

class RecallsViewModel extends ChangeNotifier {
  RecallsViewModel({required RecallRepository repository})
      : _repository = repository;

  final RecallRepository _repository;
  List<Recall> _items = const [];
  RecallDashboardStats? _stats;
  bool _loading = false;
  String? _error;

  List<Recall> get items => _items;
  RecallDashboardStats? get stats => _stats;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final listResult = await _repository.list();
    final dashboardResult = await _repository.dashboard();
    _loading = false;
    listResult.fold(
      ok: (list) => _items = list,
      err: (e) => _error = e.toString(),
    );
    dashboardResult.fold(
      ok: (stats) => _stats = stats,
      err: (e) => _error ??= e.toString(),
    );
    notifyListeners();
  }
}
