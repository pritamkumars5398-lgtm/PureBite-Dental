import 'package:flutter/widgets.dart';

import '../core/constants/app_lucide.dart';
import '../l10n/app_localizations.dart';

class AppNavItem {
  const AppNavItem({
    required this.location,
    required this.icon,
    required this.label,
  });

  final String location;
  final IconData icon;
  final String label;
}

List<AppNavItem> clinicMainNav(AppLocalizations l10n) {
  return [
    AppNavItem(location: '/', icon: AppLucide.home, label: l10n.navHome),
    AppNavItem(
      location: '/patients',
      icon: AppLucide.patients,
      label: l10n.navPatients,
    ),
    AppNavItem(
      location: '/appointments',
      icon: AppLucide.schedule,
      label: l10n.navAgenda,
    ),
    AppNavItem(
      location: '/recalls',
      icon: AppLucide.recalls,
      label: l10n.navRecalls,
    ),
    AppNavItem(
      location: '/treatment-plans',
      icon: AppLucide.treatmentPlans,
      label: l10n.navPlans,
    ),
    AppNavItem(
      location: '/budgets',
      icon: AppLucide.quotes,
      label: l10n.navQuotes,
    ),
    AppNavItem(
      location: '/invoices',
      icon: AppLucide.invoices,
      label: l10n.navInvoices,
    ),
    AppNavItem(
      location: '/payments',
      icon: AppLucide.payments,
      label: l10n.navPayments,
    ),
    AppNavItem(
      location: '/reports',
      icon: AppLucide.reports,
      label: l10n.navReports,
    ),
    AppNavItem(location: '/copilot', icon: AppLucide.ai, label: l10n.navAi),
  ];
}

/// Primary tabs on compact (phone) width. Everything else lives under More.
List<AppNavItem> clinicMobilePrimaryNav(AppLocalizations l10n) {
  return [
    AppNavItem(location: '/', icon: AppLucide.home, label: l10n.navHome),
    AppNavItem(
      location: '/patients',
      icon: AppLucide.patients,
      label: l10n.navPatients,
    ),
    AppNavItem(
      location: '/appointments',
      icon: AppLucide.schedule,
      label: l10n.navAgenda,
    ),
  ];
}

List<AppNavItem> clinicMobileMoreNav(AppLocalizations l10n) {
  const primary = {'/', '/patients', '/appointments'};
  return clinicMainNav(
    l10n,
  ).where((item) => !primary.contains(item.location)).toList();
}

int? primaryNavIndex(String location, List<AppNavItem> items) {
  for (var i = 0; i < items.length; i++) {
    if (navItemActive(items[i].location, location)) return i;
  }
  return null;
}

bool navItemActive(String location, String current) {
  if (location == '/') return current == '/';
  return current == location || current.startsWith('$location/');
}

/// Title shown in [AppChrome] for the current route (nav label, else app name).
String chromePageTitle(String location, AppLocalizations l10n) {
  for (final item in clinicMainNav(l10n)) {
    if (navItemActive(item.location, location)) return item.label;
  }
  if (navItemActive('/settings', location)) return l10n.navSettings;
  return l10n.appName;
}
