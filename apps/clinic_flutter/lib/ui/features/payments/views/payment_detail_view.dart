import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_page_header.dart';
import '../../../../ui/core/widgets/app_section_card.dart';
import '../../../../ui/core/widgets/feedback.dart';

class PaymentDetailView extends StatelessWidget {
  const PaymentDetailView({
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

    final hasPayment =
        title != null || patientName != null || status != null;
    if (!hasPayment) {
      return EmptyState(
        icon: AppLucide.payments,
        title: l10n.paymentsEmpty,
      );
    }

    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: l10n.paymentsTitle,
          subtitle: patientName,
        ),
        AppSectionCard(
          title: title ?? l10n.kpiOverduePayments,
          icon: AppLucide.payments,
          trailing: StatusBadge(label: status ?? l10n.patientStatus),
          child: Text(l10n.comingSoon, style: text.bodyMedium),
        ),
      ],
    );
  }
}
