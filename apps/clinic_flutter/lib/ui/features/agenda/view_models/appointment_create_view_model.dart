import 'package:flutter/material.dart';

import '../../../../data/repositories/appointment_repository.dart';
import '../../../../domain/models/appointment.dart';

class AppointmentCreateViewModel extends ChangeNotifier {
  AppointmentCreateViewModel({required AppointmentRepository repository})
      : _repository = repository;

  final AppointmentRepository _repository;

  String? _patientId;
  String? _professionalId;
  DateTime? _startTime;
  DateTime? _endTime;
  String? _cabinet;
  String? _cabinetId;
  String? _treatmentType;
  String? _color;

  bool _loading = false;
  Appointment? _created;
  Object? _error;

  String? get patientId => _patientId;
  String? get professionalId => _professionalId;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;
  String? get cabinet => _cabinet;
  String? get cabinetId => _cabinetId;
  String? get treatmentType => _treatmentType;
  String? get color => _color;

  bool get isLoading => _loading;
  Appointment? get created => _created;
  Object? get error => _error;

  void setPatientId(String? value) {
    _patientId = value;
    notifyListeners();
  }

  void setProfessionalId(String? value) {
    _professionalId = value;
    notifyListeners();
  }

  void setStartTime(DateTime? value) {
    _startTime = value;
    notifyListeners();
  }

  void setEndTime(DateTime? value) {
    _endTime = value;
    notifyListeners();
  }

  void setCabinet(String? value) {
    _cabinet = value;
    notifyListeners();
  }

  void setCabinetId(String? value) {
    _cabinetId = value;
    notifyListeners();
  }

  void setTreatmentType(String? value) {
    _treatmentType = value;
    notifyListeners();
  }

  void setColor(String? value) {
    _color = value;
    notifyListeners();
  }

  Future<bool> create() async {
    final patientId = _patientId?.trim() ?? '';
    final professionalId = _professionalId?.trim() ?? '';
    final start = _startTime;
    final end = _endTime;
    if (patientId.isEmpty || professionalId.isEmpty || start == null || end == null) {
      _error = 'required';
      notifyListeners();
      return false;
    }

    _loading = true;
    _created = null;
    _error = null;
    notifyListeners();
    final result = await _repository.create(
      patientId: patientId,
      professionalId: professionalId,
      startTime: start,
      endTime: end,
      cabinet: _cabinet,
      cabinetId: _cabinetId,
      treatmentType: _treatmentType,
      color: _color,
    );
    _loading = false;
    result.fold(
      ok: (appointment) => _created = appointment,
      err: (e) => _error = e,
    );
    notifyListeners();
    return result.isOk;
  }
}
