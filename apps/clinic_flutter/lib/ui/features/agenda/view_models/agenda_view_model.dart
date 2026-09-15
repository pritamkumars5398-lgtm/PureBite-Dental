import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../data/repositories/appointment_repository.dart';
import '../../../../domain/models/appointment.dart';

class AgendaViewModel extends ChangeNotifier {
  AgendaViewModel({required AppointmentRepository repository})
      : _repository = repository;

  final AppointmentRepository _repository;
  DateTime _day = DateTime.now();
  List<Appointment> _items = const [];
  bool _loading = false;

  DateTime get day => _day;
  List<Appointment> get appointments => _items;
  bool get isLoading => _loading;

  Future<void> load([DateTime? day]) async {
    if (day != null) _day = day;
    _loading = true;
    notifyListeners();
    final result = await _repository.listRange(
      start: startOfDay(_day),
      end: endOfDay(_day),
    );
    _items = result.dataOrNull ?? const [];
    _loading = false;
    notifyListeners();
  }
}
