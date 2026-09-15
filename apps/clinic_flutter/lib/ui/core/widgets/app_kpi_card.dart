import 'package:flutter/material.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import 'app_gap.dart';
import 'app_icon.dart';

class AppKpiCard extends StatelessWidget {
  const AppKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.caption,
    this.danger = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? caption;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: danger
            ? (scheme ? const Color(0xFF3A1A1A) : AppColors.dangerSoft)
            : Theme.of(context).cardTheme.color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: danger ? AppColors.dangerAccent.withValues(alpha: 0.35) : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label, style: text.labelSmall),
                ),
                AppIcon(
                  icon: icon,
                  size: AppIcons.sm,
                  color: danger ? AppColors.dangerAccent : AppColors.textSubtle,
                ),
              ],
            ),
            AppGap.xs(),
            Text(value, style: text.displayLarge),
            if (caption != null) ...[
              AppGap.xxs(),
              Text(caption!, style: text.labelSmall),
            ],
          ],
        ),
      ),
    );
  }
}
