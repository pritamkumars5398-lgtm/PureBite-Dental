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
import '../view_models/payments_view_model.dart';

class PaymentListItem {
  const PaymentListItem({
    required this.title,
    required this.patientName,
    required this.status,
  });

  final String title;
  final String patientName;
  final String status;
}

class PaymentsView extends StatefulWidget {
  const PaymentsView({
    super.key,
    this.viewModel,
    this.items = const [],
    this.isLoading = false,
    this.onAdd,
    this.onSelected,
  });

  final PaymentsViewModel? viewModel;
  final List<PaymentListItem> items;
  final bool isLoading;
  final VoidCallback? onAdd;
  final ValueChanged<PaymentListItem>? onSelected;

  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<PaymentsView> {
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    widget.viewModel?.load();
  }

  List<String> _filterLabels(AppLocalizations l10n) {
    return [
      l10n.navPayments,
      l10n.navInvoices,
      l10n.kpiOverduePayments,
    ];
  }

  List<PaymentListItem> _itemsFromViewModel(PaymentsViewModel vm) {
    return vm.payments
        .map(
          (payment) => PaymentListItem(
            title: payment.reference ??
                '${payment.netAmount} ${payment.currency}'.trim(),
            patientName: payment.patientName ?? '',
            status: payment.method,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = widget.viewModel;
    if (vm == null) {
      return _scaffold(
        l10n,
        items: widget.items,
        isLoading: widget.isLoading,
      );
    }
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return _scaffold(
          l10n,
          items: _itemsFromViewModel(vm),
          isLoading: vm.isLoading,
        );
      },
    );
  }

  Widget _scaffold(
    AppLocalizations l10n, {
    required List<PaymentListItem> items,
    required bool isLoading,
  }) {
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
            title: l10n.paymentsTitle,
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
          Expanded(child: _buildBody(l10n, items, isLoading)),
        ],
      ),
    );
  }

  Widget _buildBody(
    AppLocalizations l10n,
    List<PaymentListItem> items,
    bool isLoading,
  ) {
    if (isLoading) return const LoadingView();
    if (items.isEmpty) {
      return EmptyState(
        icon: AppLucide.payments,
        title: l10n.paymentsEmpty,
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => AppGap.sm(),
      itemBuilder: (context, index) {
        final item = items[index];
        return _PaymentListTile(
          item: item,
          onTap: widget.onSelected == null
              ? null
              : () => widget.onSelected!(item),
        );
      },
    );
  }
}

class _PaymentListTile extends StatelessWidget {
  const _PaymentListTile({
    required this.item,
    this.onTap,
  });

  final PaymentListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const AppIcon(
            icon: AppLucide.payments,
            size: AppIcons.md,
          ),
          AppGap.horizontal(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                AppGap.xxs(),
                Text(
                  item.patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall,
                ),
              ],
            ),
          ),
          AppGap.horizontal(AppSpacing.sm),
          StatusBadge(label: item.status),
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
