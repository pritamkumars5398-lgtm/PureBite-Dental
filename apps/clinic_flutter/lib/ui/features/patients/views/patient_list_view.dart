import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/patient.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_avatar.dart';
import '../../../../ui/core/widgets/app_filter_bar.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_icon.dart';
import '../../../../ui/core/widgets/data_list_layout.dart';
import '../../../../ui/core/widgets/feedback.dart';
import '../view_models/patient_list_view_model.dart';

class PatientListView extends StatefulWidget {
  const PatientListView({
    super.key,
    required this.viewModel,
    required this.onPatientSelected,
    this.onAdd,
  });

  final PatientListViewModel viewModel;
  final ValueChanged<Patient> onPatientSelected;
  final VoidCallback? onAdd;

  @override
  State<PatientListView> createState() => _PatientListViewState();
}

class _PatientListViewState extends State<PatientListView> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final statuses = widget.viewModel.patients
            .map((patient) => patient.status)
            .toSet()
            .toList()
          ..sort();
        final labels = [l10n.patientsTitle, ...statuses];
        final filterIndex =
            _filterIndex < labels.length ? _filterIndex : 0;
        final visible = filterIndex == 0
            ? widget.viewModel.patients
            : widget.viewModel.patients
                .where((patient) => patient.status == statuses[filterIndex - 1])
                .toList();

        return DataListLayout(
          title: l10n.patientsTitle,
          searchLabel: l10n.patientsSearch,
          onSearchChanged: widget.viewModel.search,
          actionLabel: widget.onAdd == null ? null : l10n.newPatient,
          actionIcon: AppLucide.userPlus,
          onAction: widget.onAdd,
          isLoading: widget.viewModel.isLoading,
          isEmpty: widget.viewModel.patients.isEmpty,
          emptyState: EmptyState(
            icon: AppLucide.people,
            title: l10n.patientsEmpty,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (statuses.isNotEmpty)
                AppFilterBar(
                  labels: labels,
                  selectedIndex: filterIndex,
                  onSelected: (index) => setState(() => _filterIndex = index),
                ),
              if (statuses.isNotEmpty) AppGap.sm(),
              Expanded(
                child: ListView.builder(
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final patient = visible[index];
                    return _PatientListTile(
                      patient: patient,
                      onTap: () => widget.onPatientSelected(patient),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PatientListTile extends StatelessWidget {
  const _PatientListTile({
    required this.patient,
    required this.onTap,
  });

  final Patient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final subtitle = patient.phone ?? patient.email ?? '—';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.tapTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                AppAvatar(
                  firstName: patient.firstName,
                  lastName: patient.lastName,
                ),
                const AppGap.horizontal(AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        patient.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      AppGap.xxs(),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelSmall,
                      ),
                    ],
                  ),
                ),
                const AppGap.horizontal(AppSpacing.sm),
                StatusBadge(
                  label: patient.status,
                  tone: _statusTone(patient.status),
                ),
                const AppGap.horizontal(AppSpacing.xs),
                const AppIcon(
                  icon: AppLucide.chevronRight,
                  size: AppIcons.md,
                  color: AppColors.textSubtle,
                ),
              ],
            ),
          ),
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
