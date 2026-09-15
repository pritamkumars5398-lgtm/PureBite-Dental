import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_avatar.dart';
import '../../../../ui/core/widgets/app_button.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_icon.dart';
import '../../../../ui/core/widgets/app_kpi_card.dart';
import '../../../../ui/core/widgets/app_page_header.dart';
import '../../../../ui/core/widgets/app_section_card.dart';
import '../../../../ui/core/widgets/feedback.dart';
import '../../../../ui/features/shell/view_models/session_controller.dart';
import '../view_models/home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.viewModel,
    required this.session,
    required this.onOpenSchedule,
    required this.onOpenPatients,
  });

  final HomeViewModel viewModel;
  final SessionController session;
  final VoidCallback onOpenSchedule;
  final VoidCallback onOpenPatients;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = widget.session.session?.user;
    final name = user?.firstName ?? '';
    final hour = DateTime.now().hour;
    final greeting = hour < 6 || hour >= 21
        ? l10n.greetingEvening(name)
        : hour < 13
            ? l10n.greetingMorning(name)
            : l10n.greetingAfternoon(name);
    final dateLabel = DateFormat.yMMMMEEEEd().format(DateTime.now());

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        if (vm.isLoading) return const LoadingView();
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            AppPageHeader(
              title: greeting,
              subtitle: dateLabel,
              actions: [
                AppButton(
                  label: l10n.newPatient,
                  icon: AppLucide.userPlus,
                  variant: AppButtonVariant.soft,
                  onPressed: widget.onOpenPatients,
                ),
                AppButton(
                  label: l10n.newAppointment,
                  icon: AppLucide.calendarPlus,
                  onPressed: widget.onOpenSchedule,
                ),
              ],
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final cards = [
                  AppKpiCard(
                    label: l10n.kpiAppointmentsToday,
                    value: '${vm.todayCount}',
                    icon: AppLucide.schedule,
                    caption: vm.todayCount == 0 ? l10n.kpiNoneToday : null,
                  ),
                  AppKpiCard(
                    label: l10n.kpiInClinicNow,
                    value: '${vm.inClinicCount}',
                    icon: AppLucide.activity,
                    caption: vm.inClinicCount == 0 ? l10n.kpiNobodyInClinic : null,
                  ),
                  AppKpiCard(
                    label: l10n.kpiOverduePayments,
                    value: '0',
                    icon: AppLucide.alert,
                    danger: false,
                  ),
                ];
                if (wide) {
                  return Row(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        Expanded(child: cards[i]),
                        if (i != cards.length - 1) AppGap.horizontal(AppSpacing.md),
                      ],
                    ],
                  );
                }
                return Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      AppGap.md(),
                    ],
                  ],
                );
              },
            ),
            AppGap.xl(),
            AppSectionCard(
              title: l10n.todayTitle,
              icon: AppLucide.clock,
              iconColor: AppColors.dangerAccent,
              trailing: TextButton(
                onPressed: widget.onOpenSchedule,
                child: Text(l10n.openSchedule),
              ),
              child: vm.today.isEmpty
                  ? EmptyState(
                      icon: AppLucide.calendarX,
                      title: l10n.todayEmpty,
                    )
                  : Column(
                      children: [
                        for (final a in vm.today)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const AppIcon(
                              icon: AppLucide.clock,
                              size: AppIcons.md,
                            ),
                            title: Text(a.patientName ?? a.treatmentType ?? a.id),
                            subtitle: Text(formatDisplayTime(a.startTime)),
                            trailing: StatusBadge(label: a.status),
                          ),
                      ],
                    ),
            ),
            AppGap.xl(),
            LayoutBuilder(
              builder: (context, constraints) {
                final unconfirmed = AppSectionCard(
                  title: l10n.unconfirmedTomorrow,
                  icon: AppLucide.schedule,
                  child: vm.tomorrowUnconfirmed.isEmpty
                      ? EmptyState(
                          icon: AppLucide.check,
                          title: l10n.unconfirmedEmpty,
                        )
                      : Column(
                          children: [
                            for (final a in vm.tomorrowUnconfirmed)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(a.patientName ?? a.id),
                                subtitle: Text(formatDisplayTime(a.startTime)),
                              ),
                          ],
                        ),
                );
                final recent = AppSectionCard(
                  title: l10n.recentPatients,
                  icon: AppLucide.patients,
                  trailing: IconButton(
                    onPressed: widget.onOpenPatients,
                    icon: const AppIcon(
                      icon: AppLucide.arrowRight,
                      size: AppIcons.md,
                    ),
                  ),
                  child: vm.recent.isEmpty
                      ? EmptyState(
                          icon: AppLucide.patients,
                          title: l10n.recentEmpty,
                        )
                      : Column(
                          children: [
                            for (final p in vm.recent)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: AppAvatar(
                                  firstName: p.firstName,
                                  lastName: p.lastName,
                                ),
                                title: Text(p.displayName),
                                subtitle: Text(p.phone ?? p.email ?? ''),
                                onTap: widget.onOpenPatients,
                              ),
                          ],
                        ),
                );
                if (constraints.maxWidth >= 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: unconfirmed),
                      AppGap.horizontal(AppSpacing.md),
                      Expanded(child: recent),
                    ],
                  );
                }
                return Column(
                  children: [
                    unconfirmed,
                    AppGap.md(),
                    recent,
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
