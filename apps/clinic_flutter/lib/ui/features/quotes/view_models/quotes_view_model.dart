import 'package:flutter/material.dart';

import '../../../../data/repositories/quote_repository.dart';
import '../../../../domain/models/quote.dart';

class QuotesViewModel extends ChangeNotifier {
  QuotesViewModel({required QuoteRepository repository})
      : _repository = repository;

  final QuoteRepository _repository;
  List<Quote> _quotes = const [];
  bool _loading = false;
  String? _error;

  List<Quote> get quotes => _quotes;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load({String? query}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.search(query: query);
    _loading = false;
    result.fold(
      ok: (list) => _quotes = list,
      err: (e) => _error = e.toString(),
    );
    notifyListeners();
  }

  Future<void> search(String query) => load(query: query);
}
