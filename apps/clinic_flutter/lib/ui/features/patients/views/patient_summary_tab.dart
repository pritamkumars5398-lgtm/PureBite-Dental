import 'package:flutter/material.dart';

import '../../../../core/constants/app_breakpoints.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_kpi_card.dart';
import '../../../../ui/core/widgets/app_section_card.dart';
import '../../../../ui/core/widgets/feedback.dart';

class PatientSummaryTab extends StatelessWidget {
  const PatientSummaryTab({super.key, this.isLoading = false});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const LoadingView();

    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              AppKpiCard(
                label: l10n.plansTitle,
                value: '0',
                icon: AppLucide.treatmentPlans,
              ),
              AppKpiCard(
                label: l10n.agendaTitle,
                value: '0',
                icon: AppLucide.schedule,
              ),
              AppKpiCard(
                label: l10n.kpiOverduePayments,
                value: '0',
                icon: AppLucide.alert,
              ),
            ];
            if (constraints.maxWidth >= AppBreakpoints.compact) {
              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    Expanded(child: cards[i]),
                    if (i != cards.length - 1)
                      AppGap.horizontal(AppSpacing.md),
                  ],
                ],
              );
            }
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final card in cards)
                  SizedBox(width: constraints.maxWidth, child: card),
              ],
            );
          },
        ),
        AppGap.md(),
        AppSectionCard(
          title: l10n.notesTitle,
          icon: AppLucide.notes,
          child: EmptyState(
            icon: AppLucide.notes,
            title: l10n.notesEmpty,
            message: l10n.comingSoon,
          ),
        ),
      ],
    );
  }
}
