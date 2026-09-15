import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../layout/window_size.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.banner,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Widget body;
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    final size = windowSizeOf(context);
    final content = Column(
      children: [
        if (banner != null) banner!,
        Expanded(child: body),
      ],
    );

    if (size == WindowSizeClass.compact) {
      return Scaffold(
        body: content,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations,
          height: AppSpacing.tapTarget + AppSpacing.md,
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            extended: size == WindowSizeClass.expanded,
            minWidth: AppSpacing.railWidth,
            minExtendedWidth: AppSpacing.railExtendedWidth,
            labelType: size == WindowSizeClass.expanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: [
              for (final d in destinations)
                NavigationRailDestination(
                  icon: d.icon,
                  selectedIcon: d.selectedIcon ?? d.icon,
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: content),
        ],
      ),
    );
  }
}
