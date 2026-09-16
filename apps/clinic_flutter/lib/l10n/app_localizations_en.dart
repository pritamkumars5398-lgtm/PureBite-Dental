// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PureBite Dental';

  @override
  String appVersion(String version) {
    return 'v$version';
  }

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginError => 'Could not sign in';

  @override
  String get loginNetworkError =>
      'Cannot reach the API at localhost:8000. Start the DentalPin backend first.';

  @override
  String get loginCredentialsError => 'Email or password is incorrect';

  @override
  String get loginPasswordShort => 'Password must be at least 8 characters';

  @override
  String get loginInvalid => 'Enter a valid email and password';

  @override
  String get navHome => 'Home';

  @override
  String get navPatients => 'Patients';

  @override
  String get navAgenda => 'Schedule';

  @override
  String get navRecalls => 'Recalls';

  @override
  String get navPlans => 'Treatment Plans';

  @override
  String get navQuotes => 'Quotes';

  @override
  String get navInvoices => 'Invoices';

  @override
  String get navPayments => 'Payments';

  @override
  String get navReports => 'Reports';

  @override
  String get navAi => 'AI';

  @override
  String get navChart => 'Chart';

  @override
  String get navNotes => 'Notes';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMenu => 'Menu';

  @override
  String get navMore => 'More';

  @override
  String get navToggleSidebar => 'Toggle sidebar';

  @override
  String get authLogout => 'Log out';

  @override
  String get help => 'Help';

  @override
  String get clinicFallback => 'Clinic';

  @override
  String daysRemaining(int days) {
    return '$days days remaining';
  }

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get newPatient => 'New patient';

  @override
  String get newAppointment => 'New appointment';

  @override
  String get kpiAppointmentsToday => 'Appointments today';

  @override
  String get kpiInClinicNow => 'In clinic now';

  @override
  String get kpiOverduePayments => 'Overdue payments';

  @override
  String get kpiNoneToday => 'No appointments today';

  @override
  String get kpiNobodyInClinic => 'No one in clinic';

  @override
  String get todayTitle => 'Today';

  @override
  String get todayEmpty => 'No appointments scheduled for today';

  @override
  String get openSchedule => 'Open schedule';

  @override
  String get unconfirmedTomorrow => 'Unconfirmed for tomorrow';

  @override
  String get unconfirmedEmpty => 'Nothing waiting to confirm';

  @override
  String get recentPatients => 'Recent patients';

  @override
  String get recentEmpty => 'No recent patients';

  @override
  String get patientsTitle => 'Patients';

  @override
  String get patientsSearch => 'Search patients';

  @override
  String get patientsEmpty => 'No patients yet';

  @override
  String get patientPhone => 'Phone';

  @override
  String get patientEmail => 'Email';

  @override
  String get patientStatus => 'Status';

  @override
  String get agendaTitle => 'Schedule';

  @override
  String get agendaEmpty => 'No appointments today';

  @override
  String get odontogramTitle => 'Dental chart';

  @override
  String get odontogramPlaceholder =>
      'Interactive chart will appear here after sync.';

  @override
  String get notesTitle => 'Clinical notes';

  @override
  String get notesEmpty => 'No notes yet';

  @override
  String get notesAdd => 'Add';

  @override
  String get notesHint => 'Write a note';

  @override
  String get recallsTitle => 'Recalls';

  @override
  String get recallsEmpty => 'No recalls in the current list.';

  @override
  String get plansTitle => 'Treatment Plans';

  @override
  String get plansEmpty => 'No treatment plans yet.';

  @override
  String get quotesTitle => 'Quotes';

  @override
  String get quotesEmpty => 'No quotes yet.';

  @override
  String get invoicesTitle => 'Invoices';

  @override
  String get invoicesEmpty => 'No invoices yet.';

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get paymentsEmpty => 'No payments recorded.';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsEmpty => 'Reports will appear here after clinic activity.';

  @override
  String get aiTitle => 'AI';

  @override
  String get aiEmpty => 'Ask the clinic copilot after the first sync.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSearch => 'Search settings...';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsGeneralDesc => 'Clinic profile, branding and timezone.';

  @override
  String get settingsWorkspace => 'Workspace';

  @override
  String get settingsWorkspaceDesc => 'Cabinets, opening hours and rooms.';

  @override
  String get settingsPeople => 'People';

  @override
  String get settingsPeopleDesc => 'Users, roles and invitations.';

  @override
  String get settingsClinical => 'Clinical';

  @override
  String get settingsClinicalDesc => 'Catalog, treatment defaults and chart.';

  @override
  String get settingsBilling => 'Billing & tax';

  @override
  String get settingsBillingDesc => 'Invoice series, VAT and tax codes.';

  @override
  String get settingsCommunications => 'Communications';

  @override
  String get settingsCommunicationsDesc => 'Notifications, SMTP and templates.';

  @override
  String get settingsIntegrations => 'Integrations';

  @override
  String get settingsIntegrationsDesc => 'External services and providers.';

  @override
  String get settingsModules => 'Modules';

  @override
  String get settingsModulesDesc => 'Install, upgrade and uninstall modules.';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsAccountDesc => 'Your profile, password and language.';

  @override
  String get settingsOnboardingTitle => 'Finish setting up your clinic';

  @override
  String get settingsOnboardingBody =>
      'You have 1 pending step to complete initial setup.';

  @override
  String get settingsOnboardingClinic => 'Complete the clinic profile';

  @override
  String get settingsOnboardingClinicDesc =>
      'Name, tax ID and address show up on quotes and invoices.';

  @override
  String get settingsDismiss => 'Dismiss';

  @override
  String get settingsClinicInfo => 'Clinic Information';

  @override
  String get settingsClinicInfoDesc =>
      'This data will appear on quotes and documents';

  @override
  String get settingsBranding => 'Branding & Appearance';

  @override
  String get settingsBrandingDesc =>
      'Customize your clinic\'s logo, primary theme, and appearance across the entire platform.';

  @override
  String get settingsCabinets => 'Cabinets';

  @override
  String get settingsCabinetsDesc =>
      'Rooms or boxes where patients are treated.';

  @override
  String get settingsUsers => 'Clinic Users';

  @override
  String get settingsUsersDesc =>
      'Accounts with access to this clinic and their roles.';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsProfileDesc => 'Your personal information in this clinic.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDesc => 'Select your preferred language';

  @override
  String get settingsClinicHours => 'Clinic hours';

  @override
  String get settingsClinicHoursDesc =>
      'Define the clinic\'s weekly opening hours and special dates (holidays, reduced hours).';

  @override
  String get settingsProfessionalHours => 'Professional schedules';

  @override
  String get settingsProfessionalHoursDesc =>
      'Set individual schedules for each professional and manage vacations or other unavailable periods.';

  @override
  String get settingsDataMigration => 'Data migration';

  @override
  String get settingsDataMigrationDesc =>
      'Import a DPMF file produced by dental-bridge (patients, appointments, budgets, payments, documents).';

  @override
  String get settingsCatalog => 'Treatment Catalog';

  @override
  String get settingsCatalogDesc =>
      'Manage treatments, pricing, and tax configuration';

  @override
  String get settingsRecallSettings => 'Recalls';

  @override
  String get settingsRecallSettingsDesc =>
      'Default intervals + treatment-category mapping';

  @override
  String get settingsSubscription => 'Clinic Subscription';

  @override
  String get settingsSubscriptionDesc =>
      'View subscription status and billing history.';

  @override
  String get settingsInvoiceSeries => 'Invoice series';

  @override
  String get settingsInvoiceSeriesDesc =>
      'Configure invoice prefixes and numbering';

  @override
  String get settingsVatTypes => 'VAT Types';

  @override
  String get settingsVatTypesDesc =>
      'Manage VAT types available for treatments';

  @override
  String get settingsQuoteExpiry => 'Expiry and auto-close';

  @override
  String get settingsQuoteExpiryDesc =>
      'How long a quote is valid before expiring and when to auto-close pending plans.';

  @override
  String get settingsQuoteReminders => 'Automatic reminders';

  @override
  String get settingsQuoteRemindersDesc =>
      'Toggle 7d / 14d email reminders to patients with no response.';

  @override
  String get settingsPublicLink => 'Public link and verification';

  @override
  String get settingsPublicLinkDesc =>
      'Configure the protection of the patient-facing quote link.';

  @override
  String get settingsVerifactu => 'Verifactu (AEAT)';

  @override
  String get settingsVerifactuDesc =>
      'Spanish e-invoicing compliance. Manage certificate, SIF producer, submission queue and fiscal ledger.';

  @override
  String get settingsCopilot => 'Copilot';

  @override
  String get settingsCopilotDesc => 'AI assistant: daily briefing and engine';

  @override
  String get comingSoon => 'This section will load clinic data after sync.';

  @override
  String get offlineBanner => 'Offline — data may not be up to date';

  @override
  String get offline => 'Offline';

  @override
  String get retry => 'Retry';

  @override
  String get subscriptionLocked => 'Subscription expired';
}
