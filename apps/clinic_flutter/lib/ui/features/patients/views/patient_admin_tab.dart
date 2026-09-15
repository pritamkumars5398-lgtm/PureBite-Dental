import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_gap.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/feedback.dart';

class PatientAdminTab extends StatelessWidget {
  const PatientAdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppSectionCard(
          title: l10n.quotesTitle,
          icon: AppLucide.quotes,
          child: EmptyState(
            icon: AppLucide.quotes,
            title: l10n.quotesEmpty,
            message: l10n.comingSoon,
          ),
        ),
        AppGap.md(),
        AppSectionCard(
          title: l10n.invoicesTitle,
          icon: AppLucide.invoices,
          child: EmptyState(
            icon: AppLucide.invoices,
            title: l10n.invoicesEmpty,
            message: l10n.comingSoon,
          ),
        ),
        AppGap.md(),
        AppSectionCard(
          title: l10n.paymentsTitle,
          icon: AppLucide.payments,
          child: EmptyState(
            icon: AppLucide.payments,
            title: l10n.paymentsEmpty,
            message: l10n.comingSoon,
          ),
        ),
      ],
    );
  }
}
