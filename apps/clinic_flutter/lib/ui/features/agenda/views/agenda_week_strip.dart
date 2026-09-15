import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';

class AgendaWeekStrip extends StatelessWidget {
  const AgendaWeekStrip({
    super.key,
    required this.selectedDay,
    required this.onSelectDay,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final monday = _mondayOfWeek(selectedDay);
    final selected = startOfDay(selectedDay);
    final dateFormat = DateFormat.Md(
      Localizations.localeOf(context).toString(),
    );
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final days = [
      for (var i = 0; i < 7; i++)
        DateTime(monday.year, monday.month, monday.day + i),
    ];

    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: _DayCell(
              day: day,
              selected: startOfDay(day) == selected,
              label: dateFormat.format(day),
              labelStyle: labelStyle,
              onSelectDay: onSelectDay,
            ),
          ),
      ],
    );
  }
}

DateTime _mondayOfWeek(DateTime day) {
  final d = startOfDay(day);
  return d.subtract(Duration(days: d.weekday - DateTime.monday));
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.label,
    required this.labelStyle,
    required this.onSelectDay,
  });

  final DateTime day;
  final bool selected;
  final String label;
  final TextStyle? labelStyle;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.primary : AppColors.border;
    final backgroundColor = selected
        ? AppColors.primarySoft
        : AppColors.surface;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: () => onSelectDay(day),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border(
              left: BorderSide(
                color: selected ? AppColors.primary : borderColor,
              ),
              top: BorderSide(color: borderColor),
              right: BorderSide(color: borderColor),
              bottom: BorderSide(color: borderColor),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSpacing.tapTarget),
            child: Center(
              child: Text(
                label,
                style: labelStyle?.copyWith(
                  color: selected
                      ? AppColors.primarySoftText
                      : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
