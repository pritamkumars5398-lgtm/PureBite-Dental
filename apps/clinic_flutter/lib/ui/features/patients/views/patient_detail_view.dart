import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/feedback.dart';
import '../view_models/patient_detail_view_model.dart';
import 'patient_admin_tab.dart';
import 'patient_clinical_tab.dart';
import 'patient_gallery_tab.dart';
import 'patient_info_tab.dart';
import 'patient_sticky_header.dart';
import 'patient_summary_tab.dart';
import 'patient_timeline_tab.dart';

class PatientDetailView extends StatelessWidget {
  const PatientDetailView({super.key, required this.viewModel});

  final PatientDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading) return const LoadingView();
        final patient = viewModel.patient;
        if (patient == null) {
          return EmptyState(
            icon: AppLucide.userX,
            title: l10n.patientsEmpty,
          );
        }

        return DefaultTabController(
          length: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PatientStickyHeader(patient: patient),
              TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: l10n.recentPatients),
                  Tab(text: l10n.patientsTitle),
                  Tab(text: l10n.odontogramTitle),
                  Tab(text: l10n.quotesTitle),
                  Tab(text: l10n.navChart),
                  Tab(text: l10n.todayTitle),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    const PatientSummaryTab(),
                    PatientInfoTab(patient: patient),
                    const PatientClinicalTab(),
                    const PatientAdminTab(),
                    const PatientGalleryTab(),
                    const PatientTimelineTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
