import 'package:flutter/material.dart';

import '../../../../data/repositories/invoice_repository.dart';
import '../../../../domain/models/invoice.dart';

class InvoicesViewModel extends ChangeNotifier {
  InvoicesViewModel({required InvoiceRepository repository})
    : _repository = repository;

  final InvoiceRepository _repository;
  List<Invoice> _invoices = const [];
  bool _loading = false;
  String? _error;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load({String? query}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.search(query: query);
    _loading = false;
    result.fold(
      ok: (list) => _invoices = list,
      err: (e) => _error = e.toString(),
    );
    notifyListeners();
  }

  Future<void> search(String query) => load(query: query);
}
