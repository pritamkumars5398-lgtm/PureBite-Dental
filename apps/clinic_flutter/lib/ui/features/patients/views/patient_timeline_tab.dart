import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/feedback.dart';

class PatientTimelineTab extends StatelessWidget {
  const PatientTimelineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: EmptyState(
        icon: AppLucide.activity,
        title: l10n.todayTitle,
        message: l10n.comingSoon,
      ),
    );
  }
}
