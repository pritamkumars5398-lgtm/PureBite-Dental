import 'package:flutter/material.dart';

import '../../../../data/repositories/catalog_repository.dart';
import '../../../../domain/models/catalog_item.dart';

class CatalogViewModel extends ChangeNotifier {
  CatalogViewModel({required CatalogRepository repository})
    : _repository = repository;

  final CatalogRepository _repository;
  List<CatalogItem> _items = const [];
  bool _loading = false;
  String? _error;

  List<CatalogItem> get items => _items;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.list();
    _loading = false;
    result.fold(ok: (list) => _items = list, err: (e) => _error = e.toString());
    notifyListeners();
  }
}
