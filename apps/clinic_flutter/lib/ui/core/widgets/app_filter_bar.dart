import 'package:flutter/material.dart';

import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

class AppFilterBar extends StatelessWidget {
  const AppFilterBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        );

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (var i = 0; i < labels.length; i++)
          _FilterChip(
            label: labels[i],
            selected: i == selectedIndex,
            labelStyle: labelStyle,
            onTap: () => onSelected(i),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.labelStyle,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final TextStyle? labelStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        selected ? AppColors.primarySoft : AppColors.surfaceMuted;
    final foregroundColor =
        selected ? AppColors.primarySoftText : AppColors.textMuted;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.tapTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Center(
              child: Text(
                label,
                style: labelStyle?.copyWith(color: foregroundColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
