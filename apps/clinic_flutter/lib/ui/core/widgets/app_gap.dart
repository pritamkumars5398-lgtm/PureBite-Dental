import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';

class AppGap extends StatelessWidget {
  const AppGap._(this.width, this.height);

  const AppGap.vertical(double size) : this._(null, size);
  const AppGap.horizontal(double size) : this._(size, null);

  factory AppGap.xxs() => const AppGap.vertical(AppSpacing.xxs);
  factory AppGap.xs() => const AppGap.vertical(AppSpacing.xs);
  factory AppGap.sm() => const AppGap.vertical(AppSpacing.sm);
  factory AppGap.md() => const AppGap.vertical(AppSpacing.md);
  factory AppGap.lg() => const AppGap.vertical(AppSpacing.lg);
  factory AppGap.xl() => const AppGap.vertical(AppSpacing.xl);
  factory AppGap.xxl() => const AppGap.vertical(AppSpacing.xxl);
  factory AppGap.xxxl() => const AppGap.vertical(AppSpacing.xxxl);

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => SizedBox(width: width, height: height);
}
