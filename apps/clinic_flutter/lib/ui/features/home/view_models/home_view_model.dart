import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../data/repositories/appointment_repository.dart';
import '../../../../data/repositories/patient_repository.dart';
import '../../../../domain/models/appointment.dart';
import '../../../../domain/models/patient.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required AppointmentRepository appointments,
    required PatientRepository patients,
  })  : _appointments = appointments,
        _patients = patients;

  final AppointmentRepository _appointments;
  final PatientRepository _patients;

  bool _loading = true;
  List<Appointment> _today = const [];
  List<Appointment> _tomorrow = const [];
  List<Patient> _recent = const [];

  bool get isLoading => _loading;
  List<Appointment> get today => _today;
  List<Appointment> get tomorrowUnconfirmed => _tomorrow
      .where((a) => a.status == 'scheduled' || a.status == 'unconfirmed')
      .toList();
  List<Patient> get recent => _recent;
  int get todayCount => _today.length;
  int get inClinicCount => _today
      .where((a) => a.status == 'checked_in' || a.status == 'in_treatment')
      .length;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final todayResult = await _appointments.listRange(
      start: startOfDay(now),
      end: endOfDay(now),
    );
    final tomorrowResult = await _appointments.listRange(
      start: startOfDay(tomorrow),
      end: endOfDay(tomorrow),
    );
    final patientsResult = await _patients.search();
    _today = todayResult.dataOrNull ?? const [];
    _tomorrow = tomorrowResult.dataOrNull ?? const [];
    _recent = (patientsResult.dataOrNull ?? const []).take(6).toList();
    _loading = false;
    notifyListeners();
  }
}
