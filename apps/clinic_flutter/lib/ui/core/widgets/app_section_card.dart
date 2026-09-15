import 'package:flutter/material.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import 'app_card.dart';
import 'app_gap.dart';
import 'app_icon.dart';

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.iconColor,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppIcon(
                icon: icon,
                size: AppIcons.md,
                color: iconColor ?? AppColors.primary,
              ),
              AppGap.horizontal(AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          AppGap.md(),
          child,
        ],
      ),
    );
  }
}
