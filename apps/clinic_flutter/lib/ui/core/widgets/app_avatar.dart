import 'package:flutter/material.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/string_utils.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.firstName,
    required this.lastName,
    this.size,
  });

  final String firstName;
  final String lastName;

  /// Diameter in logical pixels. Defaults to [AppIcons.xl]; use [AppSpacing]
  /// values (e.g. `AppSpacing.xl`, `AppSpacing.xxl`) for alternate sizes.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? AppIcons.xl;

    return CircleAvatar(
      radius: effectiveSize / 2,
      backgroundColor: AppColors.primarySoft,
      foregroundColor: AppColors.primarySoftText,
      child: Text(
        initials(firstName, lastName),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: effectiveSize * 0.375,
        ),
      ),
    );
  }
}
