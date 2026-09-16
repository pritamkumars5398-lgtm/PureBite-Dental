import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/session.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/layout/window_size.dart';
import '../../../../ui/core/widgets/app_card.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_icon.dart';
import '../../../../ui/core/widgets/app_text_field.dart';
import '../widgets/settings_hub_page.dart';
import 'branding_page.dart';
import 'cabinets_page.dart';
import 'catalog_page.dart';
import 'clinic_info_page.dart';
import 'language_page.dart';
import 'modules_page.dart';
import 'notifications_settings_page.dart';
import 'profile_page.dart';
import 'settings_stub_page.dart';
import 'users_page.dart';

class SettingsCategory {
  const SettingsCategory({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
  });

  final String id;
  final IconData icon;
  final String label;
  final String description;
}

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    required this.categoryId,
    required this.onSelectCategory,
    this.session,
  });

  final String categoryId;
  final ValueChanged<String> onSelectCategory;
  final Session? session;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String? _hubPage;

  List<SettingsCategory> _categories(AppLocalizations l10n) {
    return [
      SettingsCategory(
        id: 'general',
        icon: AppLucide.clinic,
        label: l10n.settingsGeneral,
        description: l10n.settingsGeneralDesc,
      ),
      SettingsCategory(
        id: 'workspace',
        icon: AppLucide.workspace,
        label: l10n.settingsWorkspace,
        description: l10n.settingsWorkspaceDesc,
      ),
      SettingsCategory(
        id: 'people',
        icon: AppLucide.people,
        label: l10n.settingsPeople,
        description: l10n.settingsPeopleDesc,
      ),
      SettingsCategory(
        id: 'clinical',
        icon: AppLucide.clinical,
        label: l10n.settingsClinical,
        description: l10n.settingsClinicalDesc,
      ),
      SettingsCategory(
        id: 'billing',
        icon: AppLucide.billing,
        label: l10n.settingsBilling,
        description: l10n.settingsBillingDesc,
      ),
      SettingsCategory(
        id: 'communications',
        icon: AppLucide.communications,
        label: l10n.settingsCommunications,
        description: l10n.settingsCommunicationsDesc,
      ),
      SettingsCategory(
        id: 'integrations',
        icon: AppLucide.integrations,
        label: l10n.settingsIntegrations,
        description: l10n.settingsIntegrationsDesc,
      ),
      SettingsCategory(
        id: 'modules',
        icon: AppLucide.modules,
        label: l10n.settingsModules,
        description: l10n.settingsModulesDesc,
      ),
      SettingsCategory(
        id: 'account',
        icon: AppLucide.account,
        label: l10n.settingsAccount,
        description: l10n.settingsAccountDesc,
      ),
    ];
  }

  @override
  void didUpdateWidget(SettingsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      _hubPage = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cats = _categories(l10n);
    final selected = cats.firstWhere(
      (c) => c.id == widget.categoryId,
      orElse: () => cats.first,
    );
    final compact = windowSizeOf(context) == WindowSizeClass.compact;
    final nav = _CategoryNav(
      categories: cats,
      selectedId: selected.id,
      onSelect: widget.onSelectCategory,
    );
    final pane = _categoryPane(context, l10n, selected);

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [nav],
            ),
          ),
          const Divider(height: 1),
          Expanded(flex: 2, child: pane),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppSpacing.sidebarWidth,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [nav],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: pane),
      ],
    );
  }

  Widget _categoryPane(
    BuildContext context,
    AppLocalizations l10n,
    SettingsCategory selected,
  ) {
    final opened = _openedPage(l10n);
    if (opened != null) return opened;

    return SettingsHubPage(
      title: selected.label,
      subtitle: selected.description,
      leading: selected.id == 'general'
          ? _OnboardingCard(
              l10n: l10n,
              onClinic: () => setState(() => _hubPage = 'clinic'),
            )
          : null,
      actions: [
        if (selected.id == 'general')
          SizedBox(
            width: 280,
            child: AppTextField(
              label: l10n.settingsSearch,
              prefixIcon: AppLucide.search,
            ),
          ),
      ],
      links: _links(l10n, selected.id),
    );
  }

  Widget? _openedPage(AppLocalizations l10n) {
    return switch (_hubPage) {
      'clinic' => ClinicInfoPage(session: widget.session),
      'branding' => const BrandingPage(),
      'cabinets' => const CabinetsPage(),
      'hours' => SettingsStubPage(
          title: l10n.settingsClinicHours,
          subtitle: l10n.settingsClinicHoursDesc,
          icon: AppLucide.clock,
        ),
      'professional' => SettingsStubPage(
          title: l10n.settingsProfessionalHours,
          subtitle: l10n.settingsProfessionalHoursDesc,
          icon: AppLucide.people,
        ),
      'migration' => SettingsStubPage(
          title: l10n.settingsDataMigration,
          subtitle: l10n.settingsDataMigrationDesc,
          icon: AppLucide.activity,
        ),
      'users' => UsersPage(user: widget.session?.user),
      'catalog' => const CatalogPage(),
      'recalls' => SettingsStubPage(
          title: l10n.settingsRecallSettings,
          subtitle: l10n.settingsRecallSettingsDesc,
          icon: AppLucide.recalls,
        ),
      'subscription' => SettingsStubPage(
          title: l10n.settingsSubscription,
          subtitle: l10n.settingsSubscriptionDesc,
          icon: AppLucide.creditCard,
        ),
      'invoiceSeries' => SettingsStubPage(
          title: l10n.settingsInvoiceSeries,
          subtitle: l10n.settingsInvoiceSeriesDesc,
          icon: AppLucide.hash,
        ),
      'vat' => SettingsStubPage(
          title: l10n.settingsVatTypes,
          subtitle: l10n.settingsVatTypesDesc,
          icon: AppLucide.percent,
        ),
      'quoteExpiry' => SettingsStubPage(
          title: l10n.settingsQuoteExpiry,
          subtitle: l10n.settingsQuoteExpiryDesc,
          icon: AppLucide.clock,
        ),
      'quoteReminders' => SettingsStubPage(
          title: l10n.settingsQuoteReminders,
          subtitle: l10n.settingsQuoteRemindersDesc,
          icon: AppLucide.recalls,
        ),
      'publicLink' => SettingsStubPage(
          title: l10n.settingsPublicLink,
          subtitle: l10n.settingsPublicLinkDesc,
          icon: AppLucide.lock,
        ),
      'verifactu' => SettingsStubPage(
          title: l10n.settingsVerifactu,
          subtitle: l10n.settingsVerifactuDesc,
          icon: AppLucide.invoices,
        ),
      'notifications' => const NotificationsSettingsPage(),
      'copilot' => SettingsStubPage(
          title: l10n.settingsCopilot,
          subtitle: l10n.settingsCopilotDesc,
          icon: AppLucide.ai,
        ),
      'modules' => const ModulesPage(),
      'profile' => ProfilePage(user: widget.session?.user),
      'language' => const LanguagePage(),
      _ => null,
    };
  }

  List<SettingsPageLink> _links(AppLocalizations l10n, String categoryId) {
    SettingsPageLink link(
      IconData icon,
      String title,
      String subtitle,
      String page,
    ) {
      return SettingsPageLink(
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: () => setState(() => _hubPage = page),
      );
    }

    return switch (categoryId) {
      'general' => [
          link(
            AppLucide.clinic,
            l10n.settingsClinicInfo,
            l10n.settingsClinicInfoDesc,
            'clinic',
          ),
          link(
            AppLucide.branding,
            l10n.settingsBranding,
            l10n.settingsBrandingDesc,
            'branding',
          ),
        ],
      'workspace' => [
          link(
            AppLucide.cabinets,
            l10n.settingsCabinets,
            l10n.settingsCabinetsDesc,
            'cabinets',
          ),
          link(
            AppLucide.clock,
            l10n.settingsClinicHours,
            l10n.settingsClinicHoursDesc,
            'hours',
          ),
          link(
            AppLucide.people,
            l10n.settingsProfessionalHours,
            l10n.settingsProfessionalHoursDesc,
            'professional',
          ),
          link(
            AppLucide.activity,
            l10n.settingsDataMigration,
            l10n.settingsDataMigrationDesc,
            'migration',
          ),
        ],
      'people' => [
          link(
            AppLucide.people,
            l10n.settingsUsers,
            l10n.settingsUsersDesc,
            'users',
          ),
        ],
      'clinical' => [
          link(
            AppLucide.catalog,
            l10n.settingsCatalog,
            l10n.settingsCatalogDesc,
            'catalog',
          ),
          link(
            AppLucide.recalls,
            l10n.settingsRecallSettings,
            l10n.settingsRecallSettingsDesc,
            'recalls',
          ),
        ],
      'billing' => [
          link(
            AppLucide.creditCard,
            l10n.settingsSubscription,
            l10n.settingsSubscriptionDesc,
            'subscription',
          ),
          link(
            AppLucide.hash,
            l10n.settingsInvoiceSeries,
            l10n.settingsInvoiceSeriesDesc,
            'invoiceSeries',
          ),
          link(
            AppLucide.percent,
            l10n.settingsVatTypes,
            l10n.settingsVatTypesDesc,
            'vat',
          ),
          link(
            AppLucide.clock,
            l10n.settingsQuoteExpiry,
            l10n.settingsQuoteExpiryDesc,
            'quoteExpiry',
          ),
          link(
            AppLucide.recalls,
            l10n.settingsQuoteReminders,
            l10n.settingsQuoteRemindersDesc,
            'quoteReminders',
          ),
          link(
            AppLucide.lock,
            l10n.settingsPublicLink,
            l10n.settingsPublicLinkDesc,
            'publicLink',
          ),
          link(
            AppLucide.invoices,
            l10n.settingsVerifactu,
            l10n.settingsVerifactuDesc,
            'verifactu',
          ),
        ],
      'communications' => [
          link(
            AppLucide.communications,
            l10n.settingsCommunications,
            l10n.settingsCommunicationsDesc,
            'notifications',
          ),
        ],
      'integrations' => [
          link(
            AppLucide.ai,
            l10n.settingsCopilot,
            l10n.settingsCopilotDesc,
            'copilot',
          ),
        ],
      'modules' => [
          link(
            AppLucide.modules,
            l10n.settingsModules,
            l10n.settingsModulesDesc,
            'modules',
          ),
        ],
      'account' => [
          link(
            AppLucide.profile,
            l10n.settingsProfile,
            l10n.settingsProfileDesc,
            'profile',
          ),
          link(
            AppLucide.language,
            l10n.settingsLanguage,
            l10n.settingsLanguageDesc,
            'language',
          ),
        ],
      _ => const [],
    };
  }
}

class _CategoryNav extends StatelessWidget {
  const _CategoryNav({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<SettingsCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final cat in categories)
          _CategoryTile(
            category: cat,
            selected: cat.id == selectedId,
            onTap: () => onSelect(cat.id),
          ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final SettingsCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Material(
        color: selected ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  width: 2,
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  AppIcon(
                    icon: category.icon,
                    size: AppIcons.md,
                    color: selected ? AppColors.primary : AppColors.textMuted,
                  ),
                  AppGap.horizontal(AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.label,
                          style: text.labelMedium?.copyWith(
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            color: selected ? AppColors.primarySoftText : null,
                          ),
                        ),
                        Text(
                          category.description,
                          style: text.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.l10n,
    required this.onClinic,
  });

  final AppLocalizations l10n;
  final VoidCallback onClinic;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(icon: AppLucide.clinical, size: AppIcons.md),
              AppGap.horizontal(AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.settingsOnboardingTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(l10n.settingsDismiss),
              ),
            ],
          ),
          AppGap.xs(),
          Text(l10n.settingsOnboardingBody, style: Theme.of(context).textTheme.bodyMedium),
          AppGap.md(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const AppIcon(icon: AppLucide.clinic, size: AppIcons.md),
            title: Text(l10n.settingsOnboardingClinic),
            subtitle: Text(l10n.settingsOnboardingClinicDesc),
            trailing: const AppIcon(icon: AppLucide.chevronRight, size: AppIcons.md),
            onTap: onClinic,
          ),
        ],
      ),
    );
  }
}
