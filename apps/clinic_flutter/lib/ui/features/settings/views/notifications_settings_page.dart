import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/feedback.dart';

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: l10n.settingsCommunications,
          subtitle: l10n.settingsCommunicationsDesc,
        ),
        SizedBox(
          height: AppSpacing.xxxl * 4,
          child: EmptyState(
            icon: AppLucide.communications,
            title: l10n.settingsCommunications,
            message: l10n.comingSoon,
          ),
        ),
      ],
    );
  }
}
