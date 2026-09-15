import 'package:flutter/material.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import 'app_icon.dart';

enum AppButtonVariant { solid, soft, outline, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.variant = AppButtonVariant.solid,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: AppIcons.md,
            height: AppIcons.md,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                AppIcon(icon: icon!, size: AppIcons.md),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(label),
            ],
          );

    final min = const Size(AppSpacing.tapTarget, AppSpacing.tapTarget);

    switch (variant) {
      case AppButtonVariant.solid:
        return FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(minimumSize: min),
          child: child,
        );
      case AppButtonVariant.soft:
        return FilledButton.tonal(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: min,
            backgroundColor: AppColors.primarySoft,
            foregroundColor: AppColors.primarySoftText,
          ),
          child: child,
        );
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: min,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
          child: child,
        );
      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: loading ? null : onPressed,
          style: TextButton.styleFrom(minimumSize: min),
          child: child,
        );
    }
  }
}
