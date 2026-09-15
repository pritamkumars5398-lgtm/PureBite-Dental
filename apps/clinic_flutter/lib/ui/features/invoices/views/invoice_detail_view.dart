import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_page_header.dart';
import '../../../../ui/core/widgets/app_section_card.dart';
import '../../../../ui/core/widgets/feedback.dart';

class InvoiceDetailView extends StatelessWidget {
  const InvoiceDetailView({
    super.key,
    this.title,
    this.patientName,
    this.status,
    this.isLoading = false,
  });

  final String? title;
  final String? patientName;
  final String? status;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isLoading) return const LoadingView();

    final invoiceTitle = title;
    if (invoiceTitle == null) {
      return EmptyState(
        icon: AppLucide.invoices,
        title: l10n.invoicesEmpty,
      );
    }

    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: l10n.invoicesTitle,
          subtitle: patientName,
        ),
        AppSectionCard(
          title: l10n.patientStatus,
          icon: AppLucide.invoices,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(label: status ?? invoiceTitle),
              AppGap.sm(),
              Text(l10n.comingSoon, style: text.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
