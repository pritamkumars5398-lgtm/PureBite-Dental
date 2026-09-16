import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/feedback.dart';

class PatientGalleryTab extends StatelessWidget {
  const PatientGalleryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: EmptyState(
              icon: AppLucide.clinical,
              title: l10n.patientsTitle,
              message: l10n.comingSoon,
            ),
          ),
        ],
      ),
    );
  }
}
