import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/patient.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_avatar.dart';
import '../../../../ui/core/widgets/app_button.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_icon.dart';
import '../../../../ui/core/widgets/feedback.dart';

class PatientStickyHeader extends StatelessWidget {
  const PatientStickyHeader({
    super.key,
    required this.patient,
    this.onCall,
    this.onEmail,
    this.onAdd,
  });

  final Patient patient;
  final VoidCallback? onCall;
  final VoidCallback? onEmail;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final name = patient.displayName.isEmpty ? '—' : patient.displayName;

    return Material(
      color: AppColors.surface,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.tapTarget),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            AppAvatar(
              firstName: patient.firstName,
              lastName: patient.lastName,
              size: AppSpacing.xxl,
            ),
            const AppGap.horizontal(AppSpacing.md),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Tooltip(
                      message: name,
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const AppGap.horizontal(AppSpacing.xs),
                  StatusBadge(
                    label: patient.status,
                    tone: _statusTone(patient.status),
                  ),
                ],
              ),
            ),
            if (onCall != null)
              IconButton(
                tooltip: l10n.patientPhone,
                onPressed: onCall,
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.tapTarget,
                  minHeight: AppSpacing.tapTarget,
                ),
                icon: const AppIcon(
                  icon: AppLucide.phone,
                  size: AppIcons.md,
                  color: AppColors.primary,
                ),
              ),
            if (onEmail != null)
              IconButton(
                tooltip: l10n.patientEmail,
                onPressed: onEmail,
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.tapTarget,
                  minHeight: AppSpacing.tapTarget,
                ),
                icon: const AppIcon(
                  icon: AppLucide.mail,
                  size: AppIcons.md,
                  color: AppColors.primary,
                ),
              ),
            if (onAdd != null) ...[
              const AppGap.horizontal(AppSpacing.xs),
              AppButton(
                label: l10n.notesAdd,
                icon: AppLucide.plus,
                variant: AppButtonVariant.soft,
                onPressed: onAdd,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

StatusTone _statusTone(String status) {
  return switch (status) {
    'active' => StatusTone.success,
    'inactive' => StatusTone.warning,
    'archived' => StatusTone.neutral,
    _ => StatusTone.info,
  };
}
