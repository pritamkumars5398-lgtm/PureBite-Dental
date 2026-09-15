import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/patient.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_gap.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/feedback.dart';

class PatientInfoTab extends StatelessWidget {
  const PatientInfoTab({super.key, required this.patient});

  final Patient? patient;

  static const _emptyValue = '—';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final patient = this.patient;
    if (patient == null) {
      return EmptyState(icon: AppLucide.userX, title: l10n.patientsTitle);
    }

    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppSectionCard(
          title: l10n.patientsTitle,
          icon: AppLucide.profile,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoRow(
                icon: AppLucide.phone,
                label: l10n.patientPhone,
                value: patient.phone ?? _emptyValue,
              ),
              AppGap.md(),
              _InfoRow(
                icon: AppLucide.mail,
                label: l10n.patientEmail,
                value: patient.email ?? _emptyValue,
              ),
              AppGap.md(),
              _InfoRow(
                icon: AppLucide.activity,
                label: l10n.patientStatus,
                value: patient.status,
              ),
              AppGap.md(),
              Text(l10n.comingSoon, style: text.labelSmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcon(
          icon: icon,
          size: AppIcons.md,
          color: AppColors.textSubtle,
        ),
        AppGap.horizontal(AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: text.labelMedium),
              AppGap.xxs(),
              Text(value, style: text.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
