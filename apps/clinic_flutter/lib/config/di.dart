import 'package:get_it/get_it.dart';

import '../data/repositories/appointment_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/patient_repository.dart';
import '../data/repositories/sync_engine.dart';
import '../data/services/api/api_client.dart';
import '../data/services/api/auth_interceptor.dart';
import '../data/services/connectivity/connectivity_service.dart';
import '../data/services/local/token_storage.dart';
import '../ui/features/agenda/view_models/agenda_view_model.dart';
import '../ui/features/auth/view_models/login_view_model.dart';
import '../ui/features/home/view_models/home_view_model.dart';
import '../ui/features/notes/view_models/notes_view_model.dart';
import '../ui/features/patients/view_models/patient_create_view_model.dart';
import '../ui/features/patients/view_models/patient_detail_view_model.dart';
import '../ui/features/patients/view_models/patient_list_view_model.dart';
import '../ui/features/shell/view_models/session_controller.dart';

final getIt = GetIt.instance;

Future<void> setupDi() async {
  final storage = TokenStorage();
  final connectivity = ConnectivityService();
  final api = ApiClient.create();
  final authRepository = AuthRepository(api: api, storage: storage);
  final authInterceptor = AuthInterceptor(
    readAccessToken: storage.readAccess,
    refresh: authRepository.refresh,
    onLogout: authRepository.logout,
  )..dio = api.dio;
  api.dio.interceptors.add(authInterceptor);

  final patients = PatientRepository(api: api);
  final appointments = AppointmentRepository(api: api);

  getIt
    ..registerSingleton(storage)
    ..registerSingleton(connectivity)
    ..registerSingleton(api)
    ..registerSingleton(authRepository)
    ..registerSingleton(patients)
    ..registerSingleton(appointments)
    ..registerSingleton(
      SyncEngine(
        api: api,
        connectivity: connectivity,
        patients: patients,
        appointments: appointments,
      ),
    )
    ..registerSingleton(
      SessionController(
        authRepository: authRepository,
        connectivity: connectivity,
      ),
    )
    ..registerFactory(() => LoginViewModel(session: getIt()))
    ..registerFactory(
      () => HomeViewModel(appointments: getIt(), patients: getIt()),
    )
    ..registerFactory(() => PatientListViewModel(repository: getIt()))
    ..registerFactory(() => PatientDetailViewModel(repository: getIt()))
    ..registerFactory(() => PatientCreateViewModel(repository: getIt()))
    ..registerFactory(() => AgendaViewModel(repository: getIt()))
    ..registerFactory(NotesViewModel.new);
}
