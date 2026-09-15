import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../domain/models/invoice.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_button.dart';
import '../../../../ui/core/widgets/app_card.dart';
import '../../../../ui/core/widgets/app_filter_bar.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_icon.dart';
import '../../../../ui/core/widgets/app_page_header.dart';
import '../../../../ui/core/widgets/feedback.dart';
import '../view_models/invoices_view_model.dart';

class InvoiceListItem {
  const InvoiceListItem({
    required this.title,
    required this.patientName,
    required this.status,
  });

  factory InvoiceListItem.fromInvoice(Invoice invoice) {
    return InvoiceListItem(
      title: invoice.invoiceNumber ?? invoice.id,
      patientName: invoice.patientName ?? '',
      status: invoice.status,
    );
  }

  final String title;
  final String patientName;
  final String status;
}

class InvoicesView extends StatefulWidget {
  const InvoicesView({
    super.key,
    this.viewModel,
    this.items = const [],
    this.isLoading = false,
    this.onAdd,
    this.onSelected,
  });

  final InvoicesViewModel? viewModel;
  final List<InvoiceListItem> items;
  final bool isLoading;
  final VoidCallback? onAdd;
  final ValueChanged<InvoiceListItem>? onSelected;

  @override
  State<InvoicesView> createState() => _InvoicesViewState();
}

class _InvoicesViewState extends State<InvoicesView> {
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    widget.viewModel?.load();
  }

  @override
  void didUpdateWidget(InvoicesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewModel != oldWidget.viewModel) {
      widget.viewModel?.load();
    }
  }

  List<String> _filterLabels(AppLocalizations l10n) {
    return [l10n.navInvoices, l10n.navPayments, l10n.patientStatus];
  }

  List<InvoiceListItem> get _items {
    final viewModel = widget.viewModel;
    if (viewModel != null) {
      return viewModel.invoices.map(InvoiceListItem.fromInvoice).toList();
    }
    return widget.items;
  }

  bool get _isLoading => widget.viewModel?.isLoading ?? widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    if (viewModel == null) return _buildContent(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
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
            title: l10n.invoicesTitle,
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
          Expanded(child: _buildBody(l10n)),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) return const LoadingView();
    final items = _items;
    if (items.isEmpty) {
      return EmptyState(icon: AppLucide.invoices, title: l10n.invoicesEmpty);
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => AppGap.sm(),
      itemBuilder: (context, index) {
        final item = items[index];
        return _InvoiceListTile(
          item: item,
          onTap: widget.onSelected == null
              ? null
              : () => widget.onSelected!(item),
        );
      },
    );
  }
}

class _InvoiceListTile extends StatelessWidget {
  const _InvoiceListTile({required this.item, this.onTap});

  final InvoiceListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const AppIcon(icon: AppLucide.invoices, size: AppIcons.md),
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
            const AppIcon(icon: AppLucide.chevronRight, size: AppIcons.md),
          ],
        ],
      ),
    );
  }
}
