import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_gap.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page_header.dart';

class BrandingPage extends StatelessWidget {
  const BrandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: l10n.settingsBranding,
          subtitle: l10n.settingsBrandingDesc,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppIcon(
                icon: AppLucide.branding,
                size: AppIcons.md,
                color: AppColors.primary,
              ),
              AppGap.md(),
              Center(
                child: Container(
                  width: AppSpacing.xxxl * 2,
                  height: AppSpacing.xxxl * 2,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: AppIcon(
                      icon: AppLucide.branding,
                      size: AppIcons.md,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AppGap.xl(),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: _ColorSwatch(
                  color: AppColors.primary,
                  label: _hexLabel(AppColors.primary),
                ),
              ),
              AppGap.horizontal(AppSpacing.sm),
              Expanded(
                child: _ColorSwatch(
                  color: AppColors.primaryHover,
                  label: _hexLabel(AppColors.primaryHover),
                ),
              ),
              AppGap.horizontal(AppSpacing.sm),
              Expanded(
                child: _ColorSwatch(
                  color: AppColors.primarySoft,
                  label: _hexLabel(AppColors.primarySoft),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _hexLabel(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
    return '#${value.toUpperCase()}';
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          height: AppSpacing.xxxl,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.border),
          ),
        ),
        AppGap.xs(),
        Text(
          label,
          style: text.labelSmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }
}
