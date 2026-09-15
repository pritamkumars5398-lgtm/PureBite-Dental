import 'package:flutter/material.dart';

import '../../../config/app_nav.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_lucide.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/string_utils.dart';
import '../../../domain/models/session.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_icon.dart';
import '../widgets/offline_banner.dart';
import 'window_size.dart';

class AppChrome extends StatefulWidget {
  const AppChrome({
    super.key,
    required this.location,
    required this.onNavigate,
    required this.body,
    required this.session,
    required this.offline,
    required this.onLogout,
  });

  final String location;
  final ValueChanged<String> onNavigate;
  final Widget body;
  final Session? session;
  final bool offline;
  final VoidCallback onLogout;

  @override
  State<AppChrome> createState() => _AppChromeState();
}

class _AppChromeState extends State<AppChrome> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = windowSizeOf(context);
    final items = clinicMainNav(l10n);
    final clinicName = widget.session?.clinics.isNotEmpty == true
        ? widget.session!.clinics.first.name
        : l10n.clinicFallback;
    final user = widget.session?.user;
    final daysRemaining = _daysRemaining(widget.session);

    return switch (size) {
      WindowSizeClass.compact => _mobileChrome(
        l10n: l10n,
        clinicName: clinicName,
        user: user,
      ),
      WindowSizeClass.medium => _sidebarChrome(
        l10n: l10n,
        items: items,
        clinicName: clinicName,
        user: user,
        daysRemaining: daysRemaining,
        collapsed: true,
        showSidebarToggle: false,
      ),
      WindowSizeClass.expanded => _sidebarChrome(
        l10n: l10n,
        items: items,
        clinicName: clinicName,
        user: user,
        daysRemaining: daysRemaining,
        collapsed: _collapsed,
        showSidebarToggle: true,
      ),
    };
  }

  Widget _mobileChrome({
    required AppLocalizations l10n,
    required String clinicName,
    required User? user,
  }) {
    final primary = clinicMobilePrimaryNav(l10n);
    final selected = primaryNavIndex(widget.location, primary);
    final moreIndex = primary.length;

    return Scaffold(
      body: Column(
        children: [
          _TopBar(
            compact: true,
            collapsed: false,
            clinicName: clinicName,
            onLogout: widget.onLogout,
            onSettings: () => widget.onNavigate('/settings'),
          ),
          if (widget.offline)
            OfflineBanner(offline: true, message: l10n.offlineBanner),
          Expanded(child: widget.body),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: AppSpacing.xxxl + AppSpacing.sm,
        selectedIndex: selected ?? moreIndex,
        onDestinationSelected: (index) {
          if (index < primary.length) {
            widget.onNavigate(primary[index].location);
            return;
          }
          _openMore(l10n, user);
        },
        destinations: [
          for (final item in primary)
            NavigationDestination(
              icon: AppIcon(icon: item.icon, size: AppIcons.md),
              selectedIcon: AppIcon(
                icon: item.icon,
                size: AppIcons.md,
                color: AppColors.primarySoftText,
              ),
              label: item.label,
            ),
          NavigationDestination(
            icon: const AppIcon(icon: AppLucide.more, size: AppIcons.md),
            selectedIcon: const AppIcon(
              icon: AppLucide.more,
              size: AppIcons.md,
              color: AppColors.primarySoftText,
            ),
            label: l10n.navMore,
          ),
        ],
      ),
    );
  }

  Widget _sidebarChrome({
    required AppLocalizations l10n,
    required List<AppNavItem> items,
    required String clinicName,
    required User? user,
    required int? daysRemaining,
    required bool collapsed,
    required bool showSidebarToggle,
  }) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: collapsed
                ? AppSpacing.collapsedSidebar
                : AppSpacing.sidebarWidth,
            child: _Sidebar(
              collapsed: collapsed,
              items: items,
              location: widget.location,
              onNavigate: widget.onNavigate,
              clinicName: clinicName,
              user: user,
              daysRemaining: daysRemaining,
              onSettings: () => widget.onNavigate('/settings'),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  compact: false,
                  collapsed: collapsed,
                  clinicName: clinicName,
                  onMenu: showSidebarToggle
                      ? () => setState(() => _collapsed = !_collapsed)
                      : null,
                  onLogout: widget.onLogout,
                ),
                if (widget.offline)
                  OfflineBanner(offline: true, message: l10n.offlineBanner),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMore(AppLocalizations l10n, User? user) async {
    final moreItems = clinicMobileMoreNav(l10n);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            children: [
              for (final item in moreItems)
                _NavTile(
                  item: item,
                  collapsed: false,
                  active: navItemActive(item.location, widget.location),
                  selectedColor: AppColors.primarySoft,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    widget.onNavigate(item.location);
                  },
                ),
              const Divider(height: 1),
              _NavTile(
                item: AppNavItem(
                  location: '/settings',
                  icon: AppLucide.settings,
                  label: l10n.navSettings,
                ),
                collapsed: false,
                active: navItemActive('/settings', widget.location),
                selectedColor: AppColors.primarySoft,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  widget.onNavigate('/settings');
                },
              ),
              if (user != null) _MoreUserRow(user: user),
            ],
          ),
        );
      },
    );
  }

  int? _daysRemaining(Session? session) {
    final endRaw = session?.clinics.firstOrNull?.subscriptionEndDate;
    if (endRaw == null) return null;
    final end = DateTime.tryParse(endRaw);
    if (end == null) return null;
    final days = end.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }
}

class _MoreUserRow extends StatelessWidget {
  const _MoreUserRow({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        children: [
          AppAvatar(firstName: user.firstName, lastName: user.lastName),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName(user.firstName, user.lastName),
                  style: Theme.of(context).textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.compact,
    required this.collapsed,
    required this.clinicName,
    required this.onLogout,
    this.onMenu,
    this.onSettings,
  });

  final bool compact;
  final bool collapsed;
  final String clinicName;
  final VoidCallback onLogout;
  final VoidCallback? onMenu;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        height: AppSpacing.topBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              if (onMenu != null)
                IconButton(
                  tooltip: l10n.navToggleSidebar,
                  onPressed: onMenu,
                  icon: AppIcon(
                    icon: collapsed
                        ? AppLucide.panelOpen
                        : AppLucide.panelClose,
                    size: AppIcons.md,
                  ),
                ),
              AppIcon(
                icon: AppLucide.clinic,
                size: AppIcons.sm,
                color: AppColors.textSubtle,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  clinicName,
                  style: text.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onSettings != null)
                IconButton(
                  tooltip: l10n.navSettings,
                  onPressed: onSettings,
                  icon: const AppIcon(
                    icon: AppLucide.settings,
                    size: AppIcons.md,
                  ),
                ),
              IconButton(
                tooltip: l10n.help,
                onPressed: () {},
                icon: const AppIcon(icon: AppLucide.help, size: AppIcons.md),
              ),
              if (compact)
                IconButton(
                  tooltip: l10n.authLogout,
                  onPressed: onLogout,
                  icon: const AppIcon(
                    icon: AppLucide.logout,
                    size: AppIcons.md,
                  ),
                )
              else
                TextButton.icon(
                  onPressed: onLogout,
                  icon: const AppIcon(
                    icon: AppLucide.logout,
                    size: AppIcons.md,
                  ),
                  label: Text(l10n.authLogout, style: text.labelLarge),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.collapsed,
    required this.items,
    required this.location,
    required this.onNavigate,
    required this.clinicName,
    required this.user,
    required this.daysRemaining,
    required this.onSettings,
  });

  final bool collapsed;
  final List<AppNavItem> items;
  final String location;
  final ValueChanged<String> onNavigate;
  final String clinicName;
  final User? user;
  final int? daysRemaining;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context);
    final selected = scheme.brightness == Brightness.dark
        ? AppColors.primarySoft.withValues(alpha: 0.16)
        : AppColors.primarySoft;
    return ColoredBox(
      color: scheme.brightness == Brightness.dark
          ? AppColors.surfaceMutedDark
          : AppColors.surfaceMuted,
      child: Column(
        children: [
          SizedBox(
            height: AppSpacing.topBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  const AppIcon(icon: AppLucide.clinic, size: AppIcons.lg),
                  if (!collapsed) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        clinicName,
                        style: scheme.textTheme.headlineMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              children: [
                for (final item in items)
                  _NavTile(
                    item: item,
                    collapsed: collapsed,
                    active: navItemActive(item.location, location),
                    selectedColor: selected,
                    onTap: () => onNavigate(item.location),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: collapsed
                ? Column(
                    children: [
                      AppAvatar(
                        firstName: user?.firstName ?? '?',
                        lastName: user?.lastName ?? '',
                      ),
                      IconButton(
                        tooltip: l10n.navSettings,
                        onPressed: onSettings,
                        icon: AppIcon(
                          icon: AppLucide.settings,
                          size: AppIcons.md,
                          color: navItemActive('/settings', location)
                              ? AppColors.primary
                              : null,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      AppAvatar(
                        firstName: user?.firstName ?? '?',
                        lastName: user?.lastName ?? '',
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user == null
                                  ? ''
                                  : fullName(user!.firstName, user!.lastName),
                              style: scheme.textTheme.labelMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user?.email ?? '',
                              style: scheme.textTheme.labelSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (daysRemaining != null)
                              Text(
                                l10n.daysRemaining(daysRemaining!),
                                style: scheme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.navSettings,
                        onPressed: onSettings,
                        icon: AppIcon(
                          icon: AppLucide.settings,
                          size: AppIcons.md,
                          color: navItemActive('/settings', location)
                              ? AppColors.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.collapsed,
    required this.active,
    required this.selectedColor,
    required this.onTap,
  });

  final AppNavItem item;
  final bool collapsed;
  final bool active;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.primarySoftText : AppColors.textMuted;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Tooltip(
        message: item.label,
        child: Material(
          color: active ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.tapTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    AppIcon(icon: item.icon, size: AppIcons.md, color: fg),
                    if (!collapsed) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          item.label,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: fg,
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
