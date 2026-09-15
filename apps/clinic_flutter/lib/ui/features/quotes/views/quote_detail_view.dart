import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_page_header.dart';
import '../../../../ui/core/widgets/app_section_card.dart';
import '../../../../ui/core/widgets/feedback.dart';

class QuoteDetailView extends StatelessWidget {
  const QuoteDetailView({
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
    if (title == null) {
      return EmptyState(
        icon: AppLucide.quotes,
        title: l10n.quotesEmpty,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: l10n.quotesTitle,
          subtitle: patientName,
        ),
        AppSectionCard(
          title: l10n.patientStatus,
          icon: AppLucide.quotes,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(label: status ?? l10n.comingSoon),
              AppGap.sm(),
              Text(
                l10n.comingSoon,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
