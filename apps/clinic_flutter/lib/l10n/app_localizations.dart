import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'DentalPin'**
  String get appName;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmit;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in'**
  String get loginError;

  /// No description provided for @loginNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the API at localhost:8000. Start the DentalPin backend first.'**
  String get loginNetworkError;

  /// No description provided for @loginCredentialsError.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect'**
  String get loginCredentialsError;

  /// No description provided for @loginPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get loginPasswordShort;

  /// No description provided for @loginInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email and password'**
  String get loginInvalid;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get navPatients;

  /// No description provided for @navAgenda.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navAgenda;

  /// No description provided for @navRecalls.
  ///
  /// In en, this message translates to:
  /// **'Recalls'**
  String get navRecalls;

  /// No description provided for @navPlans.
  ///
  /// In en, this message translates to:
  /// **'Treatment Plans'**
  String get navPlans;

  /// No description provided for @navQuotes.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get navQuotes;

  /// No description provided for @navInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get navInvoices;

  /// No description provided for @navPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get navPayments;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navAi;

  /// No description provided for @navChart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get navChart;

  /// No description provided for @navNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get navNotes;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @navToggleSidebar.
  ///
  /// In en, this message translates to:
  /// **'Toggle sidebar'**
  String get navToggleSidebar;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get authLogout;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @clinicFallback.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinicFallback;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String daysRemaining(int days);

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @newPatient.
  ///
  /// In en, this message translates to:
  /// **'New patient'**
  String get newPatient;

  /// No description provided for @newAppointment.
  ///
  /// In en, this message translates to:
  /// **'New appointment'**
  String get newAppointment;

  /// No description provided for @kpiAppointmentsToday.
  ///
  /// In en, this message translates to:
  /// **'Appointments today'**
  String get kpiAppointmentsToday;

  /// No description provided for @kpiInClinicNow.
  ///
  /// In en, this message translates to:
  /// **'In clinic now'**
  String get kpiInClinicNow;

  /// No description provided for @kpiOverduePayments.
  ///
  /// In en, this message translates to:
  /// **'Overdue payments'**
  String get kpiOverduePayments;

  /// No description provided for @kpiNoneToday.
  ///
  /// In en, this message translates to:
  /// **'No appointments today'**
  String get kpiNoneToday;

  /// No description provided for @kpiNobodyInClinic.
  ///
  /// In en, this message translates to:
  /// **'No one in clinic'**
  String get kpiNobodyInClinic;

  /// No description provided for @todayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTitle;

  /// No description provided for @todayEmpty.
  ///
  /// In en, this message translates to:
  /// **'No appointments scheduled for today'**
  String get todayEmpty;

  /// No description provided for @openSchedule.
  ///
  /// In en, this message translates to:
  /// **'Open schedule'**
  String get openSchedule;

  /// No description provided for @unconfirmedTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Unconfirmed for tomorrow'**
  String get unconfirmedTomorrow;

  /// No description provided for @unconfirmedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting to confirm'**
  String get unconfirmedEmpty;

  /// No description provided for @recentPatients.
  ///
  /// In en, this message translates to:
  /// **'Recent patients'**
  String get recentPatients;

  /// No description provided for @recentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent patients'**
  String get recentEmpty;

  /// No description provided for @patientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patientsTitle;

  /// No description provided for @patientsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search patients'**
  String get patientsSearch;

  /// No description provided for @patientsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No patients yet'**
  String get patientsEmpty;

  /// No description provided for @patientPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get patientPhone;

  /// No description provided for @patientEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get patientEmail;

  /// No description provided for @patientStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get patientStatus;

  /// No description provided for @agendaTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get agendaTitle;

  /// No description provided for @agendaEmpty.
  ///
  /// In en, this message translates to:
  /// **'No appointments today'**
  String get agendaEmpty;

  /// No description provided for @odontogramTitle.
  ///
  /// In en, this message translates to:
  /// **'Dental chart'**
  String get odontogramTitle;

  /// No description provided for @odontogramPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Interactive chart will appear here after sync.'**
  String get odontogramPlaceholder;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical notes'**
  String get notesTitle;

  /// No description provided for @notesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get notesEmpty;

  /// No description provided for @notesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get notesAdd;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Write a note'**
  String get notesHint;

  /// No description provided for @recallsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recalls'**
  String get recallsTitle;

  /// No description provided for @recallsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recalls in the current list.'**
  String get recallsEmpty;

  /// No description provided for @plansTitle.
  ///
  /// In en, this message translates to:
  /// **'Treatment Plans'**
  String get plansTitle;

  /// No description provided for @plansEmpty.
  ///
  /// In en, this message translates to:
  /// **'No treatment plans yet.'**
  String get plansEmpty;

  /// No description provided for @quotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get quotesTitle;

  /// No description provided for @quotesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No quotes yet.'**
  String get quotesEmpty;

  /// No description provided for @invoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoicesTitle;

  /// No description provided for @invoicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet.'**
  String get invoicesEmpty;

  /// No description provided for @paymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsTitle;

  /// No description provided for @paymentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded.'**
  String get paymentsEmpty;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Reports will appear here after clinic activity.'**
  String get reportsEmpty;

  /// No description provided for @aiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiTitle;

  /// No description provided for @aiEmpty.
  ///
  /// In en, this message translates to:
  /// **'Ask the clinic copilot after the first sync.'**
  String get aiEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search settings...'**
  String get settingsSearch;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'Clinic profile, branding and timezone.'**
  String get settingsGeneralDesc;

  /// No description provided for @settingsWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get settingsWorkspace;

  /// No description provided for @settingsWorkspaceDesc.
  ///
  /// In en, this message translates to:
  /// **'Cabinets, opening hours and rooms.'**
  String get settingsWorkspaceDesc;

  /// No description provided for @settingsPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get settingsPeople;

  /// No description provided for @settingsPeopleDesc.
  ///
  /// In en, this message translates to:
  /// **'Users, roles and invitations.'**
  String get settingsPeopleDesc;

  /// No description provided for @settingsClinical.
  ///
  /// In en, this message translates to:
  /// **'Clinical'**
  String get settingsClinical;

  /// No description provided for @settingsClinicalDesc.
  ///
  /// In en, this message translates to:
  /// **'Catalog, treatment defaults and chart.'**
  String get settingsClinicalDesc;

  /// No description provided for @settingsBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing & tax'**
  String get settingsBilling;

  /// No description provided for @settingsBillingDesc.
  ///
  /// In en, this message translates to:
  /// **'Invoice series, VAT and tax codes.'**
  String get settingsBillingDesc;

  /// No description provided for @settingsCommunications.
  ///
  /// In en, this message translates to:
  /// **'Communications'**
  String get settingsCommunications;

  /// No description provided for @settingsCommunicationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications, SMTP and templates.'**
  String get settingsCommunicationsDesc;

  /// No description provided for @settingsIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get settingsIntegrations;

  /// No description provided for @settingsIntegrationsDesc.
  ///
  /// In en, this message translates to:
  /// **'External services and providers.'**
  String get settingsIntegrationsDesc;

  /// No description provided for @settingsModules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get settingsModules;

  /// No description provided for @settingsModulesDesc.
  ///
  /// In en, this message translates to:
  /// **'Install, upgrade and uninstall modules.'**
  String get settingsModulesDesc;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Your profile, password and language.'**
  String get settingsAccountDesc;

  /// No description provided for @settingsOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up your clinic'**
  String get settingsOnboardingTitle;

  /// No description provided for @settingsOnboardingBody.
  ///
  /// In en, this message translates to:
  /// **'You have 1 pending step to complete initial setup.'**
  String get settingsOnboardingBody;

  /// No description provided for @settingsOnboardingClinic.
  ///
  /// In en, this message translates to:
  /// **'Complete the clinic profile'**
  String get settingsOnboardingClinic;

  /// No description provided for @settingsOnboardingClinicDesc.
  ///
  /// In en, this message translates to:
  /// **'Name, tax ID and address show up on quotes and invoices.'**
  String get settingsOnboardingClinicDesc;

  /// No description provided for @settingsDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get settingsDismiss;

  /// No description provided for @settingsClinicInfo.
  ///
  /// In en, this message translates to:
  /// **'Clinic Information'**
  String get settingsClinicInfo;

  /// No description provided for @settingsClinicInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'This data will appear on quotes and documents'**
  String get settingsClinicInfoDesc;

  /// No description provided for @settingsBranding.
  ///
  /// In en, this message translates to:
  /// **'Branding & Appearance'**
  String get settingsBranding;

  /// No description provided for @settingsBrandingDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize your clinic\'s logo, primary theme, and appearance across the entire platform.'**
  String get settingsBrandingDesc;

  /// No description provided for @settingsCabinets.
  ///
  /// In en, this message translates to:
  /// **'Cabinets'**
  String get settingsCabinets;

  /// No description provided for @settingsCabinetsDesc.
  ///
  /// In en, this message translates to:
  /// **'Rooms or boxes where patients are treated.'**
  String get settingsCabinetsDesc;

  /// No description provided for @settingsUsers.
  ///
  /// In en, this message translates to:
  /// **'Clinic Users'**
  String get settingsUsers;

  /// No description provided for @settingsUsersDesc.
  ///
  /// In en, this message translates to:
  /// **'Accounts with access to this clinic and their roles.'**
  String get settingsUsersDesc;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Your personal information in this clinic.'**
  String get settingsProfileDesc;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsClinicHours.
  ///
  /// In en, this message translates to:
  /// **'Clinic hours'**
  String get settingsClinicHours;

  /// No description provided for @settingsClinicHoursDesc.
  ///
  /// In en, this message translates to:
  /// **'Define the clinic\'s weekly opening hours and special dates (holidays, reduced hours).'**
  String get settingsClinicHoursDesc;

  /// No description provided for @settingsProfessionalHours.
  ///
  /// In en, this message translates to:
  /// **'Professional schedules'**
  String get settingsProfessionalHours;

  /// No description provided for @settingsProfessionalHoursDesc.
  ///
  /// In en, this message translates to:
  /// **'Set individual schedules for each professional and manage vacations or other unavailable periods.'**
  String get settingsProfessionalHoursDesc;

  /// No description provided for @settingsDataMigration.
  ///
  /// In en, this message translates to:
  /// **'Data migration'**
  String get settingsDataMigration;

  /// No description provided for @settingsDataMigrationDesc.
  ///
  /// In en, this message translates to:
  /// **'Import a DPMF file produced by dental-bridge (patients, appointments, budgets, payments, documents).'**
  String get settingsDataMigrationDesc;

  /// No description provided for @settingsCatalog.
  ///
  /// In en, this message translates to:
  /// **'Treatment Catalog'**
  String get settingsCatalog;

  /// No description provided for @settingsCatalogDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage treatments, pricing, and tax configuration'**
  String get settingsCatalogDesc;

  /// No description provided for @settingsRecallSettings.
  ///
  /// In en, this message translates to:
  /// **'Recalls'**
  String get settingsRecallSettings;

  /// No description provided for @settingsRecallSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Default intervals + treatment-category mapping'**
  String get settingsRecallSettingsDesc;

  /// No description provided for @settingsSubscription.
  ///
  /// In en, this message translates to:
  /// **'Clinic Subscription'**
  String get settingsSubscription;

  /// No description provided for @settingsSubscriptionDesc.
  ///
  /// In en, this message translates to:
  /// **'View subscription status and billing history.'**
  String get settingsSubscriptionDesc;

  /// No description provided for @settingsInvoiceSeries.
  ///
  /// In en, this message translates to:
  /// **'Invoice series'**
  String get settingsInvoiceSeries;

  /// No description provided for @settingsInvoiceSeriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure invoice prefixes and numbering'**
  String get settingsInvoiceSeriesDesc;

  /// No description provided for @settingsVatTypes.
  ///
  /// In en, this message translates to:
  /// **'VAT Types'**
  String get settingsVatTypes;

  /// No description provided for @settingsVatTypesDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage VAT types available for treatments'**
  String get settingsVatTypesDesc;

  /// No description provided for @settingsQuoteExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry and auto-close'**
  String get settingsQuoteExpiry;

  /// No description provided for @settingsQuoteExpiryDesc.
  ///
  /// In en, this message translates to:
  /// **'How long a quote is valid before expiring and when to auto-close pending plans.'**
  String get settingsQuoteExpiryDesc;

  /// No description provided for @settingsQuoteReminders.
  ///
  /// In en, this message translates to:
  /// **'Automatic reminders'**
  String get settingsQuoteReminders;

  /// No description provided for @settingsQuoteRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Toggle 7d / 14d email reminders to patients with no response.'**
  String get settingsQuoteRemindersDesc;

  /// No description provided for @settingsPublicLink.
  ///
  /// In en, this message translates to:
  /// **'Public link and verification'**
  String get settingsPublicLink;

  /// No description provided for @settingsPublicLinkDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure the protection of the patient-facing quote link.'**
  String get settingsPublicLinkDesc;

  /// No description provided for @settingsVerifactu.
  ///
  /// In en, this message translates to:
  /// **'Verifactu (AEAT)'**
  String get settingsVerifactu;

  /// No description provided for @settingsVerifactuDesc.
  ///
  /// In en, this message translates to:
  /// **'Spanish e-invoicing compliance. Manage certificate, SIF producer, submission queue and fiscal ledger.'**
  String get settingsVerifactuDesc;

  /// No description provided for @settingsCopilot.
  ///
  /// In en, this message translates to:
  /// **'Copilot'**
  String get settingsCopilot;

  /// No description provided for @settingsCopilotDesc.
  ///
  /// In en, this message translates to:
  /// **'AI assistant: daily briefing and engine'**
  String get settingsCopilotDesc;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'This section will load clinic data after sync.'**
  String get comingSoon;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline — data may not be up to date'**
  String get offlineBanner;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @subscriptionLocked.
  ///
  /// In en, this message translates to:
  /// **'Subscription expired'**
  String get subscriptionLocked;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
