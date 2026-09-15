import 'package:flutter/material.dart';

import '../../../../data/repositories/payment_repository.dart';
import '../../../../domain/models/payment.dart';

class PaymentsViewModel extends ChangeNotifier {
  PaymentsViewModel({required PaymentRepository repository})
      : _repository = repository;

  final PaymentRepository _repository;
  List<Payment> _payments = const [];
  PaymentAging? _aging;
  bool _loading = false;
  String? _error;

  List<Payment> get payments => _payments;
  PaymentAging? get aging => _aging;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final listResult = await _repository.list();
    final agingResult = await _repository.aging();
    _loading = false;
    listResult.fold(
      ok: (list) => _payments = list,
      err: (e) => _error = e.toString(),
    );
    agingResult.fold(
      ok: (value) => _aging = value,
      err: (e) => _error ??= e.toString(),
    );
    notifyListeners();
  }
}
