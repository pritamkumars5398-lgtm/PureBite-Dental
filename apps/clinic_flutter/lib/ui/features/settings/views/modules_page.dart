import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_page_header.dart';
import '../../../../ui/core/widgets/feedback.dart';

class ModulesPage extends StatelessWidget {
  const ModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: l10n.settingsModules,
          subtitle: l10n.settingsModulesDesc,
        ),
        SizedBox(
          height: AppSpacing.xxxl * 4,
          child: EmptyState(
            icon: AppLucide.modules,
            title: l10n.settingsModules,
            message: l10n.comingSoon,
          ),
        ),
      ],
    );
  }
}
