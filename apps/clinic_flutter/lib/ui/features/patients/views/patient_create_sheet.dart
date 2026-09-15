import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_button.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_page_header.dart';
import '../../../../ui/core/widgets/app_text_field.dart';
import '../view_models/patient_create_view_model.dart';

class PatientCreateSheet extends StatelessWidget {
  const PatientCreateSheet({super.key, required this.viewModel});

  final PatientCreateViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
        ),
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(title: l10n.newPatient),
                AppTextField(
                  label: l10n.patientsTitle,
                  controller: viewModel.nameController,
                  textInputAction: TextInputAction.next,
                ),
                AppGap.md(),
                AppTextField(
                  label: l10n.patientPhone,
                  controller: viewModel.phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                AppGap.md(),
                AppTextField(
                  label: l10n.patientEmail,
                  controller: viewModel.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),
                AppGap.lg(),
                AppButton(
                  label: l10n.notesAdd,
                  loading: viewModel.isLoading,
                  onPressed: () async {
                    final ok = await viewModel.create();
                    if (ok && context.mounted) {
                      Navigator.of(context).pop(viewModel.created);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
