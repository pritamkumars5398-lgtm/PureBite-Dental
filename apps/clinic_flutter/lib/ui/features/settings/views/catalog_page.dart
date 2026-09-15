import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/catalog_item.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_card.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_page_header.dart';
import '../../../../ui/core/widgets/feedback.dart';
import '../view_models/catalog_view_model.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key, this.viewModel});

  final CatalogViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    if (vm == null) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          AppPageHeader(
            title: l10n.settingsCatalog,
            subtitle: l10n.settingsCatalogDesc,
          ),
          SizedBox(
            height: AppSpacing.xxxl * 4,
            child: EmptyState(
              icon: AppLucide.catalog,
              title: l10n.settingsCatalog,
              message: l10n.comingSoon,
            ),
          ),
        ],
      );
    }

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            AppPageHeader(
              title: l10n.settingsCatalog,
              subtitle: l10n.settingsCatalogDesc,
            ),
            if (vm.isLoading)
              const SizedBox(height: AppSpacing.xxxl * 4, child: LoadingView())
            else if (vm.items.isEmpty)
              SizedBox(
                height: AppSpacing.xxxl * 4,
                child: EmptyState(
                  icon: AppLucide.catalog,
                  title: l10n.settingsCatalog,
                  message: vm.error ?? l10n.comingSoon,
                ),
              )
            else
              for (var i = 0; i < vm.items.length; i++) ...[
                if (i > 0) AppGap.md(),
                _CatalogItemRow(
                  item: vm.items[i],
                  locale: Localizations.localeOf(context).languageCode,
                ),
              ],
          ],
        );
      },
    );
  }
}

class _CatalogItemRow extends StatelessWidget {
  const _CatalogItemRow({required this.item, required this.locale});

  final CatalogItem item;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.tapTarget),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.localizedName(locale),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            AppGap.xxs(),
            Text(
              item.internalCode,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
