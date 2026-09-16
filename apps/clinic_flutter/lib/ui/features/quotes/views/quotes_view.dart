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
import '../view_models/quotes_view_model.dart';

class QuoteListItem {
  const QuoteListItem({
    required this.title,
    required this.patientName,
    required this.status,
  });

  final String title;
  final String patientName;
  final String status;
}

class QuotesView extends StatefulWidget {
  const QuotesView({
    super.key,
    this.viewModel,
    this.items = const [],
    this.isLoading = false,
    this.onAdd,
    this.onSelected,
  });

  final QuotesViewModel? viewModel;
  final List<QuoteListItem> items;
  final bool isLoading;
  final VoidCallback? onAdd;
  final ValueChanged<QuoteListItem>? onSelected;

  @override
  State<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends State<QuotesView> {
  int _selectedFilter = 0;

  List<String> _filterLabels(AppLocalizations l10n) {
    return [
      l10n.navQuotes,
      l10n.navInvoices,
      l10n.patientStatus,
    ];
  }

  @override
  void initState() {
    super.initState();
    widget.viewModel?.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    if (vm == null) {
      return _buildScaffold(
        items: widget.items,
        isLoading: widget.isLoading,
      );
    }
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return _buildScaffold(
          items: vm.quotes
              .map(
                (quote) => QuoteListItem(
                  title: quote.number,
                  patientName: quote.patientName,
                  status: quote.status,
                ),
              )
              .toList(),
          isLoading: vm.isLoading,
        );
      },
    );
  }

  Widget _buildScaffold({
    required List<QuoteListItem> items,
    required bool isLoading,
  }) {
    final l10n = AppLocalizations.of(context);

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
            title: l10n.quotesTitle,
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
          Expanded(child: _buildBody(l10n, items: items, isLoading: isLoading)),
        ],
      ),
    );
  }

  Widget _buildBody(
    AppLocalizations l10n, {
    required List<QuoteListItem> items,
    required bool isLoading,
  }) {
    if (isLoading) return const LoadingView();
    if (items.isEmpty) {
      return EmptyState(
        icon: AppLucide.quotes,
        title: l10n.quotesEmpty,
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => AppGap.sm(),
      itemBuilder: (context, index) {
        final item = items[index];
        return _QuoteListTile(
          item: item,
          onTap: widget.onSelected == null
              ? null
              : () => widget.onSelected!(item),
        );
      },
    );
  }
}

class _QuoteListTile extends StatelessWidget {
  const _QuoteListTile({
    required this.item,
    this.onTap,
  });

  final QuoteListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const AppIcon(
            icon: AppLucide.quotes,
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
