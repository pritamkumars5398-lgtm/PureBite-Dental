import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_button.dart';
import '../../../../ui/core/widgets/app_card.dart';
import '../../../../ui/core/widgets/app_filter_bar.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_icon.dart';
import '../../../../ui/core/widgets/app_page_header.dart';
import '../../../../ui/core/widgets/feedback.dart';
import '../view_models/treatment_plans_view_model.dart';

class TreatmentPlanListItem {
  const TreatmentPlanListItem({
    required this.title,
    required this.patientName,
    required this.status,
  });

  final String title;
  final String patientName;
  final String status;
}

class TreatmentPlansView extends StatefulWidget {
  const TreatmentPlansView({
    super.key,
    this.viewModel,
    this.plans = const [],
    this.isLoading = false,
    this.onAdd,
    this.onPlanSelected,
  });

  final TreatmentPlansViewModel? viewModel;
  final List<TreatmentPlanListItem> plans;
  final bool isLoading;
  final VoidCallback? onAdd;
  final ValueChanged<TreatmentPlanListItem>? onPlanSelected;

  @override
  State<TreatmentPlansView> createState() => _TreatmentPlansViewState();
}

class _TreatmentPlansViewState extends State<TreatmentPlansView> {
  int _selectedFilter = 0;

  List<String> _filterLabels(AppLocalizations l10n) {
    return [
      l10n.navPlans,
      l10n.navQuotes,
      l10n.agendaTitle,
      l10n.patientStatus,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    if (viewModel == null) {
      return _buildContent(
        AppLocalizations.of(context),
        widget.plans,
        widget.isLoading,
      );
    }
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return _buildContent(
          AppLocalizations.of(context),
          _itemsFromViewModel(viewModel),
          viewModel.isLoading,
        );
      },
    );
  }

  List<TreatmentPlanListItem> _itemsFromViewModel(
    TreatmentPlansViewModel viewModel,
  ) {
    return viewModel.plans
        .map(
          (plan) => TreatmentPlanListItem(
            title: plan.displayTitle,
            patientName: plan.patientName ?? '',
            status: plan.status,
          ),
        )
        .toList();
  }

  Widget _buildContent(
    AppLocalizations l10n,
    List<TreatmentPlanListItem> plans,
    bool isLoading,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: l10n.plansTitle,
            showTitle: false,
            actions: [
              if (widget.onAdd != null)
                AppButton(
                  label: l10n.notesAdd,
                  icon: AppLucide.plus,
                  onPressed: widget.onAdd,
                ),
            ],
          ),
          AppFilterBar(
            labels: _filterLabels(l10n),
            selectedIndex: _selectedFilter,
            onSelected: (index) => setState(() => _selectedFilter = index),
          ),
          AppGap.md(),
          Expanded(child: _buildBody(l10n, plans, isLoading)),
        ],
      ),
    );
  }

  Widget _buildBody(
    AppLocalizations l10n,
    List<TreatmentPlanListItem> plans,
    bool isLoading,
  ) {
    if (isLoading) return const LoadingView();
    if (plans.isEmpty) {
      return EmptyState(
        icon: AppLucide.treatmentPlans,
        title: l10n.plansEmpty,
      );
    }
    return ListView.separated(
      itemCount: plans.length,
      separatorBuilder: (_, _) => AppGap.sm(),
      itemBuilder: (context, index) {
        final plan = plans[index];
        return _PlanListTile(
          plan: plan,
          onTap: widget.onPlanSelected == null
              ? null
              : () => widget.onPlanSelected!(plan),
        );
      },
    );
  }
}

class _PlanListTile extends StatelessWidget {
  const _PlanListTile({
    required this.plan,
    this.onTap,
  });

  final TreatmentPlanListItem plan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const AppIcon(
            icon: AppLucide.treatmentPlans,
            size: AppIcons.md,
          ),
          AppGap.horizontal(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                AppGap.xxs(),
                Text(
                  plan.patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall,
                ),
              ],
            ),
          ),
          AppGap.horizontal(AppSpacing.sm),
          StatusBadge(label: plan.status),
          if (onTap != null) ...[
            AppGap.horizontal(AppSpacing.xs),
            const AppIcon(
              icon: AppLucide.chevronRight,
              size: AppIcons.md,
            ),
          ],
        ],
      ),
    );
  }
}
