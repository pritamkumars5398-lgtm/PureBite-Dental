import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import 'app_gap.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showTitle = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hasTitle = showTitle && title.isNotEmpty;
    if (!hasTitle && subtitle == null && actions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle) Text(title, style: text.displayLarge),
                if (subtitle != null) ...[
                  if (hasTitle) AppGap.xxs(),
                  Text(subtitle!, style: text.labelSmall),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty)
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: actions,
            ),
        ],
      ),
    );
  }
}
