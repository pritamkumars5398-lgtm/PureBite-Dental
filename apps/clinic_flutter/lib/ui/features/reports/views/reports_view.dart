import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_gap.dart';
import '../../../core/widgets/app_kpi_card.dart';
import '../../../core/widgets/feedback.dart';
import '../view_models/reports_view_model.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key, this.viewModel});

  final ReportsViewModel? viewModel;

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel?.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    if (vm == null) return _body(context);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => _body(context, viewModel: vm),
    );
  }

  Widget _body(BuildContext context, {ReportsViewModel? viewModel}) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 600;
            final cards = [
              AppKpiCard(
                label: l10n.navQuotes,
                value: viewModel?.kpiValue(0) ?? '0',
                icon: AppLucide.quotes,
                caption: l10n.reportsEmpty,
              ),
              AppKpiCard(
                label: l10n.navInvoices,
                value: viewModel?.kpiValue(1) ?? '0',
                icon: AppLucide.invoices,
                caption: l10n.reportsEmpty,
              ),
              AppKpiCard(
                label: l10n.navPayments,
                value: viewModel?.kpiValue(2) ?? '0',
                icon: AppLucide.payments,
                caption: l10n.reportsEmpty,
              ),
              AppKpiCard(
                label: l10n.kpiOverduePayments,
                value: viewModel?.kpiValue(3) ?? '0',
                icon: AppLucide.alert,
                caption: l10n.reportsEmpty,
                danger: true,
              ),
            ];
            if (wide) {
              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    Expanded(child: cards[i]),
                    if (i != cards.length - 1) AppGap.horizontal(AppSpacing.md),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < cards.length; i += 2) ...[
                  Row(
                    children: [
                      Expanded(child: cards[i]),
                      AppGap.horizontal(AppSpacing.md),
                      Expanded(child: cards[i + 1]),
                    ],
                  ),
                  if (i + 2 < cards.length) AppGap.md(),
                ],
              ],
            );
          },
        ),
        AppGap.xl(),
        SizedBox(
          height: AppSpacing.xxxl * 4,
          child: EmptyState(
            icon: AppLucide.reports,
            title: l10n.reportsTitle,
            message: l10n.reportsEmpty,
          ),
        ),
      ],
    );
  }
}
