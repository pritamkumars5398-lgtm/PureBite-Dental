import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_section_card.dart';
import '../../../../ui/core/widgets/feedback.dart';

class PatientClinicalTab extends StatelessWidget {
  const PatientClinicalTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppSectionCard(
          title: l10n.odontogramTitle,
          icon: AppLucide.chart,
          child: EmptyState(
            icon: AppLucide.chart,
            title: l10n.odontogramPlaceholder,
          ),
        ),
        AppGap.md(),
        AppSectionCard(
          title: l10n.plansTitle,
          icon: AppLucide.treatmentPlans,
          child: EmptyState(
            icon: AppLucide.treatmentPlans,
            title: l10n.plansEmpty,
          ),
        ),
        AppGap.md(),
        AppSectionCard(
          title: l10n.agendaTitle,
          icon: AppLucide.schedule,
          child: EmptyState(
            icon: AppLucide.schedule,
            title: l10n.agendaEmpty,
          ),
        ),
        AppGap.md(),
        AppSectionCard(
          title: l10n.notesTitle,
          icon: AppLucide.notes,
          child: EmptyState(
            icon: AppLucide.notes,
            title: l10n.notesEmpty,
          ),
        ),
      ],
    );
  }
}
