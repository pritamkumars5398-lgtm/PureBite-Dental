import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/models/appointment.dart';
import '../../../../ui/core/widgets/app_card.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_icon.dart';
import '../../../../ui/core/widgets/feedback.dart';
import '../view_models/agenda_view_model.dart';
import 'agenda_week_strip.dart';

class AgendaView extends StatelessWidget {
  const AgendaView({super.key, required this.viewModel});

  final AgendaViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.agendaTitle,
                style: textTheme.headlineLarge,
              ),
              AppGap.xl(),
              AgendaWeekStrip(
                selectedDay: viewModel.day,
                onSelectDay: (day) => viewModel.load(day),
              ),
              AppGap.md(),
              _DaySelector(
                day: viewModel.day,
                onPrevious: () => viewModel.load(
                  viewModel.day.subtract(const Duration(days: 1)),
                ),
                onNext: () => viewModel.load(
                  viewModel.day.add(const Duration(days: 1)),
                ),
              ),
              AppGap.xl(),
              Expanded(
                child: _buildBody(context, l10n, textTheme),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    if (viewModel.isLoading) return const LoadingView();
    if (viewModel.appointments.isEmpty) {
      return EmptyState(
        icon: AppLucide.calendarX,
        title: l10n.agendaEmpty,
      );
    }
    return ListView.separated(
      itemCount: viewModel.appointments.length,
      separatorBuilder: (_, _) => AppGap.xl(),
      itemBuilder: (context, index) {
        return _AppointmentCard(
          appointment: viewModel.appointments[index],
          textTheme: textTheme,
        );
      },
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.day,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime day;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const AppIcon(
            icon: AppLucide.chevronLeft,
            size: AppIcons.md,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            formatDisplayDate(day),
            style: textTheme.labelLarge,
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const AppIcon(
            icon: AppLucide.chevronRight,
            size: AppIcons.md,
          ),
        ),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.textTheme,
  });

  final Appointment appointment;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppIcon(
            icon: AppLucide.clock,
            size: AppIcons.md,
          ),
          const AppGap.horizontal(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDisplayDateTime(appointment.startTime),
                  style: textTheme.labelSmall,
                ),
                AppGap.md(),
                Text(
                  appointment.patientName ?? '—',
                  style: textTheme.bodyLarge,
                ),
                if (appointment.treatmentType != null) ...[
                  AppGap.md(),
                  Text(
                    appointment.treatmentType!,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          AppGap.horizontal(AppSpacing.md),
          StatusBadge(
            label: appointment.status,
            tone: _statusTone(appointment.status),
          ),
        ],
      ),
    );
  }
}

StatusTone _statusTone(String status) {
  switch (status) {
    case 'scheduled':
      return StatusTone.info;
    case 'confirmed':
      return StatusTone.success;
    case 'checked_in':
    case 'in_treatment':
      return StatusTone.warning;
    case 'completed':
      return StatusTone.neutral;
    case 'cancelled':
    case 'no_show':
      return StatusTone.danger;
    default:
      return StatusTone.neutral;
  }
}
