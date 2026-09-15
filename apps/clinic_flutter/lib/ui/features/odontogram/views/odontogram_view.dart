import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../ui/core/widgets/app_card.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_icon.dart';
import '../view_models/odontogram_view_model.dart';

enum _ToothState { intact, planned, done }

abstract final class _OdontogramData {
  static const upperRight = [18, 17, 16, 15, 14, 13, 12, 11];
  static const upperLeft = [21, 22, 23, 24, 25, 26, 27, 28];
  static const lowerRight = [48, 47, 46, 45, 44, 43, 42, 41];
  static const lowerLeft = [31, 32, 33, 34, 35, 36, 37, 38];

  static const sampleStates = <int, _ToothState>{
    16: _ToothState.planned,
    26: _ToothState.planned,
    36: _ToothState.done,
    46: _ToothState.done,
  };
}

(Color background, Color border) _colorsForState(_ToothState state) {
  return switch (state) {
    _ToothState.intact => (AppColors.surfaceMuted, AppColors.border),
    _ToothState.planned => (AppColors.infoSoft, AppColors.infoAccent),
    _ToothState.done => (AppColors.successSoft, AppColors.successAccent),
  };
}

class OdontogramView extends StatelessWidget {
  const OdontogramView({super.key, this.patientId, this.viewModel});

  final String? patientId;
  final OdontogramViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    if (vm == null) return _buildChart(context, null);
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => _buildChart(context, vm),
    );
  }

  Widget _buildChart(BuildContext context, OdontogramViewModel? vm) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: AppIcon(icon: LucideIcons.smile, size: AppIcons.xl),
            ),
            AppGap.md(),
            Text(
              l10n.odontogramTitle,
              style: text.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            AppGap.xs(),
            Text(
              l10n.odontogramPlaceholder,
              style: text.bodyMedium,
            ),
            AppGap.lg(),
            _OdontogramChart(viewModel: vm),
            AppGap.lg(),
            const _OdontogramLegend(),
          ],
        ),
      ),
    );
  }
}

class _OdontogramChart extends StatelessWidget {
  const _OdontogramChart({this.viewModel});

  final OdontogramViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToothRow(
          rightQuadrant: _OdontogramData.upperRight,
          leftQuadrant: _OdontogramData.upperLeft,
          viewModel: viewModel,
        ),
        AppGap.sm(),
        _ToothRow(
          rightQuadrant: _OdontogramData.lowerRight,
          leftQuadrant: _OdontogramData.lowerLeft,
          viewModel: viewModel,
        ),
      ],
    );
  }
}

class _ToothRow extends StatelessWidget {
  const _ToothRow({
    required this.rightQuadrant,
    required this.leftQuadrant,
    this.viewModel,
  });

  final List<int> rightQuadrant;
  final List<int> leftQuadrant;
  final OdontogramViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ToothQuadrant(numbers: rightQuadrant, viewModel: viewModel),
        AppGap.horizontal(AppSpacing.sm),
        _ToothQuadrant(numbers: leftQuadrant, viewModel: viewModel),
      ],
    );
  }
}

class _ToothQuadrant extends StatelessWidget {
  const _ToothQuadrant({required this.numbers, this.viewModel});

  final List<int> numbers;
  final OdontogramViewModel? viewModel;

  _ToothState _stateFor(int fdi) {
    final vm = viewModel;
    if (vm == null || !vm.hasData) {
      return _OdontogramData.sampleStates[fdi] ?? _ToothState.intact;
    }
    return switch (vm.cellState(fdi)) {
      OdontogramCellState.intact => _ToothState.intact,
      OdontogramCellState.planned => _ToothState.planned,
      OdontogramCellState.done => _ToothState.done,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < numbers.length; i++) ...[
          if (i > 0) AppGap.horizontal(AppSpacing.xxs),
          _ToothCell(
            fdi: numbers[i],
            state: _stateFor(numbers[i]),
          ),
        ],
      ],
    );
  }
}

class _ToothCell extends StatelessWidget {
  const _ToothCell({required this.fdi, required this.state});

  final int fdi;
  final _ToothState state;

  @override
  Widget build(BuildContext context) {
    final (background, border) = _colorsForState(state);
    return Semantics(
      label: 'FDI $fdi',
      child: Container(
        width: AppIcons.md,
        height: AppIcons.md,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: border),
        ),
      ),
    );
  }
}

class _OdontogramLegend extends StatelessWidget {
  const _OdontogramLegend();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        _LegendItem(
          label: 'Intact',
          state: _ToothState.intact,
          textStyle: text.labelSmall,
        ),
        _LegendItem(
          label: 'Planned',
          state: _ToothState.planned,
          textStyle: text.labelSmall,
        ),
        _LegendItem(
          label: 'Done',
          state: _ToothState.done,
          textStyle: text.labelSmall,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.state,
    required this.textStyle,
  });

  final String label;
  final _ToothState state;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final (background, border) = _colorsForState(state);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppIcons.md,
          height: AppIcons.md,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: border),
          ),
        ),
        AppGap.horizontal(AppSpacing.xxs),
        Text(label, style: textStyle),
      ],
    );
  }
}
