import '../../core/constants/api_constants.dart';

int normalizePage(int page) => page < 1 ? 1 : page;

int clampPatientPageSize(int size) {
  if (size < 1) return ApiConstants.patientsPageSize;
  if (size > ApiConstants.patientsPageSizeMax) {
    return ApiConstants.patientsPageSizeMax;
  }
  return size;
}

int clampAppointmentPageSize(int size) {
  if (size < 1) return ApiConstants.appointmentsPageSize;
  if (size > ApiConstants.appointmentsPageSizeMax) {
    return ApiConstants.appointmentsPageSizeMax;
  }
  return size;
}
