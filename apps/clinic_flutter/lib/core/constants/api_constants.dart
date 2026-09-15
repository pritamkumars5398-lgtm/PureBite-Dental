/// All REST paths, headers, and paging caps.
///
/// Never put URL strings anywhere else. See docs/03-api-constants.md.
abstract final class ApiConstants {
  static const String defaultBaseUrl = 'http://localhost:8000';
  static const String apiV1 = '/api/v1';

  static const String login = '$apiV1/auth/login';
  static const String refresh = '$apiV1/auth/refresh';
  static const String me = '$apiV1/auth/me';
  static const String logout = '$apiV1/auth/logout';

  static const String patients = '$apiV1/patients';
  static const String patientsRecent = '$apiV1/patients/recent';

  static String patient(String id) => '$patients/$id';
  static String patientExtended(String id) => '$patients/$id/extended';

  static const String appointments = '$apiV1/agenda/appointments';
  static const String cabinets = '$apiV1/agenda/cabinets';

  static String appointment(String id) => '$appointments/$id';

  static const String budgets = '$apiV1/budget/budgets';
  static String budget(String id) => '$budgets/$id';

  static const String invoices = '$apiV1/billing/invoices';
  static String invoice(String id) => '$invoices/$id';

  static const String payments = '$apiV1/payments';
  static String payment(String id) => '$payments/$id';
  static const String paymentsAging = '$apiV1/payments/reports/aging-receivables';

  static const String recalls = '$apiV1/recalls/';
  static const String recallsDashboard = '$apiV1/recalls/stats/dashboard';
  static String recall(String id) => '$apiV1/recalls/$id';

  static const String treatmentPlans = '$apiV1/treatment-plans';
  static String treatmentPlan(String id) => '$treatmentPlans/$id';

  static const String catalogItems = '$apiV1/catalog/items';
  static const String vatTypes = '$apiV1/catalog/vat-types';
  static const String clinicUsers = '$apiV1/auth/users';
  static const String copilotPending = '$apiV1/copilot/pending';
  static const String copilotSessions = '$apiV1/copilot/sessions';
  static String copilotSessionMessages(String conversationId) =>
      '$copilotSessions/$conversationId/messages';
  static const String clinics = '$apiV1/auth/clinics';
  static String clinic(String id) => '$clinics/$id';

  static const String odontogram = '$apiV1/odontogram';
  static String odontogramPatient(String patientId) =>
      '$odontogram/patients/$patientId';

  static const String clinicalNotes = '$apiV1/clinical_notes';

  static const String authorization = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String contentType = 'Content-Type';
  static const String json = 'application/json';
  static const String formUrlEncoded = 'application/x-www-form-urlencoded';

  static const String extraSkipAuth = 'skipAuth';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 60);

  static const int patientsPageSize = 20;
  static const int patientsPageSizeMax = 100;
  static const int appointmentsPageSize = 100;
  static const int appointmentsPageSizeMax = 500;

  static const String queryPage = 'page';
  static const String queryPageSize = 'page_size';
  static const String querySearch = 'search';
  static const String queryClinicId = 'clinic_id';
  static const String queryStartDate = 'start_date';
  static const String queryEndDate = 'end_date';
  static const String queryStatus = 'status';
  static const String queryPatientId = 'patient_id';
  static const String queryIncludeArchived = 'include_archived';
}
