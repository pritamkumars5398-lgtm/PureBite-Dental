import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_page_header.dart';
import '../widgets/feedback.dart';

class ModulePlaceholderPage extends StatelessWidget {
  const ModulePlaceholderPage({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: title,
          showTitle: false,
          actions: [
            if (actionLabel != null)
              AppButton(
                label: actionLabel!,
                icon: icon,
                onPressed: onAction,
              ),
          ],
        ),
        SizedBox(
          height: AppSpacing.xxxl * 4,
          child: EmptyState(
            icon: icon,
            title: title,
            message: message,
          ),
        ),
      ],
    );
  }
}
