import 'package:flutter/material.dart';

import '../../../core/constants/app_icons.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.tooltip,
    this.semanticLabel,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final String? tooltip;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final child = Icon(
      icon,
      size: size ?? AppIcons.md,
      color: color,
      semanticLabel: semanticLabel,
    );
    if (tooltip == null) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}
