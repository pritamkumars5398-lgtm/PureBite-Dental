import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/feedback.dart';

class SettingsStubPage extends StatelessWidget {
  const SettingsStubPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(title: title, subtitle: subtitle),
        SizedBox(
          height: AppSpacing.xxxl * 4,
          child: EmptyState(
            icon: icon,
            title: title,
            message: l10n.comingSoon,
          ),
        ),
      ],
    );
  }
}
