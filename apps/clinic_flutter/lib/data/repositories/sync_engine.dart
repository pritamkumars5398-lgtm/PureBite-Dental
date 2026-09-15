import 'package:clinic_flutter/data/repositories/appointment_repository.dart';
import 'package:clinic_flutter/data/repositories/patient_repository.dart';
import 'package:clinic_flutter/data/services/api/api_client.dart';
import 'package:clinic_flutter/data/services/connectivity/connectivity_service.dart';

class SyncEngine {
  SyncEngine({
    required ApiClient api,
    ConnectivityService? connectivity,
    PatientRepository? patients,
    AppointmentRepository? appointments,
  })  : _connectivity = connectivity,
        _patients = patients,
        _appointments = appointments;

  final ConnectivityService? _connectivity;
  final PatientRepository? _patients;
  final AppointmentRepository? _appointments;

  Future<void> flushOutbox() async {}

  Future<void> pullAll() async {
    final online = await _connectivity?.isOnline ?? true;
    if (!online) return;
    await _patients?.pullRemote();
    final now = DateTime.now();
    await _appointments?.listRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }
}
