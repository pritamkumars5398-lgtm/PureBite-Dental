// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'DentalPin';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginEmail => 'Correo';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginSubmit => 'Entrar';

  @override
  String get loginError => 'No se pudo iniciar sesión';

  @override
  String get loginNetworkError =>
      'No se puede conectar a la API en localhost:8000. Arranca el backend de DentalPin.';

  @override
  String get loginCredentialsError => 'Correo o contraseña incorrectos';

  @override
  String get loginPasswordShort =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get loginInvalid => 'Introduce un correo y una contraseña válidos';

  @override
  String get navHome => 'Inicio';

  @override
  String get navPatients => 'Pacientes';

  @override
  String get navAgenda => 'Agenda';

  @override
  String get navRecalls => 'Recordatorios';

  @override
  String get navPlans => 'Planes de tratamiento';

  @override
  String get navQuotes => 'Presupuestos';

  @override
  String get navInvoices => 'Facturas';

  @override
  String get navPayments => 'Cobros';

  @override
  String get navReports => 'Informes';

  @override
  String get navAi => 'IA';

  @override
  String get navChart => 'Odontograma';

  @override
  String get navNotes => 'Notas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navMenu => 'Menú';

  @override
  String get navMore => 'Más';

  @override
  String get navToggleSidebar => 'Alternar barra lateral';

  @override
  String get authLogout => 'Salir';

  @override
  String get help => 'Ayuda';

  @override
  String get clinicFallback => 'Clínica';

  @override
  String daysRemaining(int days) {
    return '$days días restantes';
  }

  @override
  String greetingMorning(String name) {
    return 'Buenos días, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Buenas tardes, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Buenas noches, $name';
  }

  @override
  String get newPatient => 'Nuevo paciente';

  @override
  String get newAppointment => 'Nueva cita';

  @override
  String get kpiAppointmentsToday => 'Citas de hoy';

  @override
  String get kpiInClinicNow => 'En clínica ahora';

  @override
  String get kpiOverduePayments => 'Pagos vencidos';

  @override
  String get kpiNoneToday => 'No hay citas hoy';

  @override
  String get kpiNobodyInClinic => 'Nadie en clínica';

  @override
  String get todayTitle => 'Hoy';

  @override
  String get todayEmpty => 'No hay citas programadas para hoy';

  @override
  String get openSchedule => 'Abrir agenda';

  @override
  String get unconfirmedTomorrow => 'Sin confirmar para mañana';

  @override
  String get unconfirmedEmpty => 'Nada pendiente de confirmar';

  @override
  String get recentPatients => 'Pacientes recientes';

  @override
  String get recentEmpty => 'No hay pacientes recientes';

  @override
  String get patientsTitle => 'Pacientes';

  @override
  String get patientsSearch => 'Buscar pacientes';

  @override
  String get patientsEmpty => 'Todavía no hay pacientes';

  @override
  String get patientPhone => 'Teléfono';

  @override
  String get patientEmail => 'Correo';

  @override
  String get patientStatus => 'Estado';

  @override
  String get agendaTitle => 'Agenda';

  @override
  String get agendaEmpty => 'No hay citas hoy';

  @override
  String get odontogramTitle => 'Odontograma';

  @override
  String get odontogramPlaceholder =>
      'El odontograma interactivo aparecerá aquí tras la sincronización.';

  @override
  String get notesTitle => 'Notas clínicas';

  @override
  String get notesEmpty => 'Todavía no hay notas';

  @override
  String get notesAdd => 'Añadir';

  @override
  String get notesHint => 'Escribe una nota';

  @override
  String get recallsTitle => 'Recordatorios';

  @override
  String get recallsEmpty => 'No hay recordatorios en la lista actual.';

  @override
  String get plansTitle => 'Planes de tratamiento';

  @override
  String get plansEmpty => 'Todavía no hay planes.';

  @override
  String get quotesTitle => 'Presupuestos';

  @override
  String get quotesEmpty => 'Todavía no hay presupuestos.';

  @override
  String get invoicesTitle => 'Facturas';

  @override
  String get invoicesEmpty => 'Todavía no hay facturas.';

  @override
  String get paymentsTitle => 'Cobros';

  @override
  String get paymentsEmpty => 'No hay cobros registrados.';

  @override
  String get reportsTitle => 'Informes';

  @override
  String get reportsEmpty =>
      'Los informes aparecerán tras la actividad de la clínica.';

  @override
  String get aiTitle => 'IA';

  @override
  String get aiEmpty => 'Pregunta al copilot tras la primera sincronización.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSearch => 'Buscar ajustes...';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsGeneralDesc => 'Perfil de clínica, marca y zona horaria.';

  @override
  String get settingsWorkspace => 'Espacio de trabajo';

  @override
  String get settingsWorkspaceDesc => 'Gabinetes, horario y salas.';

  @override
  String get settingsPeople => 'Personas';

  @override
  String get settingsPeopleDesc => 'Usuarios, roles e invitaciones.';

  @override
  String get settingsClinical => 'Clínico';

  @override
  String get settingsClinicalDesc =>
      'Catálogo, valores de tratamiento y odontograma.';

  @override
  String get settingsBilling => 'Facturación e impuestos';

  @override
  String get settingsBillingDesc => 'Series, IVA y códigos fiscales.';

  @override
  String get settingsCommunications => 'Comunicaciones';

  @override
  String get settingsCommunicationsDesc => 'Notificaciones, SMTP y plantillas.';

  @override
  String get settingsIntegrations => 'Integraciones';

  @override
  String get settingsIntegrationsDesc => 'Servicios y proveedores externos.';

  @override
  String get settingsModules => 'Módulos';

  @override
  String get settingsModulesDesc =>
      'Instalar, actualizar y desinstalar módulos.';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsAccountDesc => 'Perfil, contraseña e idioma.';

  @override
  String get settingsOnboardingTitle => 'Termina de configurar tu clínica';

  @override
  String get settingsOnboardingBody =>
      'Tienes 1 paso pendiente para completar la configuración inicial.';

  @override
  String get settingsOnboardingClinic => 'Completa el perfil de la clínica';

  @override
  String get settingsOnboardingClinicDesc =>
      'Nombre, NIF y dirección aparecen en presupuestos y facturas.';

  @override
  String get settingsDismiss => 'Descartar';

  @override
  String get settingsClinicInfo => 'Información de la clínica';

  @override
  String get settingsClinicInfoDesc =>
      'Estos datos aparecen en presupuestos y documentos';

  @override
  String get settingsBranding => 'Marca y apariencia';

  @override
  String get settingsBrandingDesc =>
      'Personaliza el logo, el color principal y la apariencia de la plataforma.';

  @override
  String get settingsCabinets => 'Gabinetes';

  @override
  String get settingsCabinetsDesc =>
      'Salas o boxes donde se atiende a pacientes.';

  @override
  String get settingsUsers => 'Usuarios de la clínica';

  @override
  String get settingsUsersDesc =>
      'Cuentas con acceso a esta clínica y sus roles.';

  @override
  String get settingsProfile => 'Perfil';

  @override
  String get settingsProfileDesc => 'Tu información personal en esta clínica.';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageDesc => 'Selecciona tu idioma preferido';

  @override
  String get settingsClinicHours => 'Horario de la clínica';

  @override
  String get settingsClinicHoursDesc =>
      'Define el horario de apertura semanal y los días especiales (festivos, horario reducido).';

  @override
  String get settingsProfessionalHours => 'Horarios de profesionales';

  @override
  String get settingsProfessionalHoursDesc =>
      'Configura el horario individual de cada profesional y gestiona vacaciones u otros períodos sin disponibilidad.';

  @override
  String get settingsDataMigration => 'Migración de datos';

  @override
  String get settingsDataMigrationDesc =>
      'Importa un archivo DPMF generado por dental-bridge (pacientes, citas, presupuestos, pagos, documentos).';

  @override
  String get settingsCatalog => 'Catálogo de tratamientos';

  @override
  String get settingsCatalogDesc =>
      'Gestiona los tratamientos, precios y configuración fiscal';

  @override
  String get settingsRecallSettings => 'Recordatorios';

  @override
  String get settingsRecallSettingsDesc =>
      'Intervalos por motivo y mapeo de tratamientos';

  @override
  String get settingsSubscription => 'Suscripción de la clínica';

  @override
  String get settingsSubscriptionDesc =>
      'Ver el estado de la suscripción y el historial de facturación.';

  @override
  String get settingsInvoiceSeries => 'Series de facturación';

  @override
  String get settingsInvoiceSeriesDesc =>
      'Configura los prefijos y numeración de facturas';

  @override
  String get settingsVatTypes => 'Tipos de IVA';

  @override
  String get settingsVatTypesDesc =>
      'Gestiona los tipos de IVA disponibles para los tratamientos';

  @override
  String get settingsQuoteExpiry => 'Caducidad y auto-cierre';

  @override
  String get settingsQuoteExpiryDesc =>
      'Define cuántos días vale un presupuesto antes de caducar y cuándo cerrar automáticamente los planes.';

  @override
  String get settingsQuoteReminders => 'Recordatorios automáticos';

  @override
  String get settingsQuoteRemindersDesc =>
      'Activa los recordatorios a los 7 y 14 días sin respuesta del paciente.';

  @override
  String get settingsPublicLink => 'Link público y verificación';

  @override
  String get settingsPublicLinkDesc =>
      'Configura la protección del link del presupuesto que ve el paciente.';

  @override
  String get settingsVerifactu => 'Verifactu (AEAT)';

  @override
  String get settingsVerifactuDesc =>
      'Cumplimiento de facturación electrónica para España. Gestiona certificado, productor del SIF, cola de envío y libro fiscal.';

  @override
  String get settingsCopilot => 'Copilot';

  @override
  String get settingsCopilotDesc => 'Asistente de IA: briefing diario y motor';

  @override
  String get comingSoon =>
      'Esta sección cargará datos de la clínica tras la sincronización.';

  @override
  String get offlineBanner =>
      'Sin conexión — los datos pueden no estar actualizados';

  @override
  String get offline => 'Sin conexión';

  @override
  String get retry => 'Reintentar';

  @override
  String get subscriptionLocked => 'Suscripción caducada';
}
