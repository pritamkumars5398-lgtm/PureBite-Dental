import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_gap.dart';
import '../../../core/widgets/app_kpi_card.dart';
import '../../../core/widgets/feedback.dart';
import '../view_models/recalls_view_model.dart';

class RecallsView extends StatefulWidget {
  const RecallsView({super.key, this.viewModel});

  final RecallsViewModel? viewModel;

  @override
  State<RecallsView> createState() => _RecallsViewState();
}

class _RecallsViewState extends State<RecallsView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel?.load();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    if (viewModel == null) {
      return _RecallsBody(viewModel: null);
    }
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => _RecallsBody(viewModel: viewModel),
    );
  }
}

class _RecallsBody extends StatelessWidget {
  const _RecallsBody({required this.viewModel});

  final RecallsViewModel? viewModel;

  String _kpi(int? value) => '${value ?? 0}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = viewModel?.stats;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 600;
            final cards = [
              AppKpiCard(
                label: l10n.todayTitle,
                value: _kpi(stats?.dueThisWeek),
                icon: AppLucide.clock,
                caption: l10n.recallsEmpty,
              ),
              AppKpiCard(
                label: l10n.kpiOverduePayments,
                value: _kpi(stats?.overdue),
                icon: AppLucide.alert,
                caption: l10n.recallsEmpty,
                danger: true,
              ),
              AppKpiCard(
                label: l10n.unconfirmedTomorrow,
                value: _kpi(stats?.scheduledThisMonth),
                icon: AppLucide.schedule,
                caption: l10n.recallsEmpty,
              ),
              AppKpiCard(
                label: l10n.navRecalls,
                value: _kpi(stats?.completedThisMonth),
                icon: AppLucide.check,
                caption: l10n.recallsEmpty,
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
            icon: AppLucide.recalls,
            title: l10n.recallsTitle,
            message: l10n.recallsEmpty,
          ),
        ),
      ],
    );
  }
}
