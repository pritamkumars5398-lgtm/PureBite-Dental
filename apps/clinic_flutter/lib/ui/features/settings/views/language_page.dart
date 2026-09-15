import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_card.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_icon.dart';
import '../../../../ui/core/widgets/app_page_header.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  static const _locales = [Locale('en'), Locale('es')];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: l10n.settingsLanguage,
          subtitle: l10n.settingsLanguageDesc,
        ),
        for (final locale in _locales) ...[
          AppCard(
            onTap: () {},
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const AppIcon(
                icon: AppLucide.language,
                size: AppIcons.md,
              ),
              title: Text(locale.toLanguageTag()),
              subtitle: Text(l10n.settingsLanguageDesc),
              trailing: const AppIcon(
                icon: AppLucide.chevronRight,
                size: AppIcons.md,
              ),
            ),
          ),
          if (locale != _locales.last) AppGap.md(),
        ],
      ],
    );
  }
}
