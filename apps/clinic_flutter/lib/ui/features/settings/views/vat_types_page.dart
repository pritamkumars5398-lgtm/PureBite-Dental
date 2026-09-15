import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/vat_type.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_gap.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/feedback.dart';

class VatTypesPage extends StatelessWidget {
  const VatTypesPage({super.key, this.types});

  final List<VatType>? types;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final items = types ?? const <VatType>[];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: l10n.settingsVatTypes,
          subtitle: l10n.settingsVatTypesDesc,
        ),
        if (items.isEmpty)
          SizedBox(
            height: AppSpacing.xxxl * 4,
            child: EmptyState(
              icon: AppLucide.percent,
              title: l10n.settingsVatTypes,
              message: l10n.comingSoon,
            ),
          )
        else
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) AppGap.md(),
                  _VatTypeRow(type: items[i], locale: locale),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _VatTypeRow extends StatelessWidget {
  const _VatTypeRow({required this.type, required this.locale});

  final VatType type;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.tapTarget),
      child: Row(
        children: [
          Expanded(
            child: Text(
              type.localizedName(locale),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          AppGap.horizontal(AppSpacing.sm),
          Text(
            type.rateLabel,
            style: text.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
