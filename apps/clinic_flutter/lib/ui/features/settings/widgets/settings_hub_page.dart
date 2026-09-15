import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_gap.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page_header.dart';

class SettingsPageLink {
  const SettingsPageLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class SettingsHubPage extends StatelessWidget {
  const SettingsHubPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.links,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<SettingsPageLink> links;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: title,
          subtitle: subtitle,
          actions: actions,
        ),
        if (leading != null) ...[
          leading!,
          AppGap.xl(),
        ],
        SettingsLinkGrid(links: links),
      ],
    );
  }
}

class SettingsLinkGrid extends StatelessWidget {
  const SettingsLinkGrid({super.key, required this.links});

  final List<SettingsPageLink> links;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumn = constraints.maxWidth >= 700 && links.length > 1;
        if (!twoColumn) {
          return Column(
            children: [
              for (var i = 0; i < links.length; i++) ...[
                if (i > 0) AppGap.md(),
                SettingsLinkCard(link: links[i]),
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < links.length; i += 2) {
          if (i > 0) rows.add(AppGap.md());
          final second = i + 1 < links.length ? links[i + 1] : null;
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SettingsLinkCard(link: links[i])),
                AppGap.horizontal(AppSpacing.md),
                Expanded(
                  child: second == null
                      ? const SizedBox.shrink()
                      : SettingsLinkCard(link: second),
                ),
              ],
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}

class SettingsLinkCard extends StatelessWidget {
  const SettingsLinkCard({super.key, required this.link});

  final SettingsPageLink link;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: link.onTap,
      child: Row(
        children: [
          AppIcon(icon: link.icon, size: AppIcons.md, color: AppColors.primary),
          AppGap.horizontal(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(link.title, style: Theme.of(context).textTheme.headlineSmall),
                AppGap.xxs(),
                Text(link.subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const AppIcon(icon: AppLucide.chevronRight, size: AppIcons.md),
        ],
      ),
    );
  }
}
