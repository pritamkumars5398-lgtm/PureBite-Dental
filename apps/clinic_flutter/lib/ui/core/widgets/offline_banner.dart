import 'package:flutter/material.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import 'app_icon.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.offline,
    required this.message,
  });

  final bool offline;
  final String message;

  @override
  Widget build(BuildContext context) {
    if (!offline) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.warningSoft,
        border: Border(
          left: BorderSide(color: AppColors.warningAccent, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const AppIcon(
              icon: Icons.wifi_off,
              size: AppIcons.md,
              color: AppColors.warningAccent,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warningText,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
