import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/cabinet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_gap.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/feedback.dart';
import '../view_models/cabinets_view_model.dart';

class CabinetsPage extends StatefulWidget {
  const CabinetsPage({super.key, this.viewModel});

  final CabinetsViewModel? viewModel;

  @override
  State<CabinetsPage> createState() => _CabinetsPageState();
}

class _CabinetsPageState extends State<CabinetsPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel?.load();
  }

  @override
  void didUpdateWidget(covariant CabinetsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewModel != oldWidget.viewModel) {
      widget.viewModel?.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = widget.viewModel;
    if (vm == null) {
      return _page(l10n, child: _empty(l10n));
    }
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        if (vm.isLoading) {
          return _page(l10n, child: const LoadingView());
        }
        final cabinets = vm.cabinets;
        if (cabinets.isEmpty) {
          return _page(l10n, child: _empty(l10n));
        }
        return _page(
          l10n,
          child: Column(
            children: [
              for (var i = 0; i < cabinets.length; i++) ...[
                if (i > 0) AppGap.sm(),
                _CabinetRow(cabinet: cabinets[i]),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _page(AppLocalizations l10n, {required Widget child}) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: l10n.settingsCabinets,
          subtitle: l10n.settingsCabinetsDesc,
        ),
        child,
      ],
    );
  }

  Widget _empty(AppLocalizations l10n) {
    return SizedBox(
      height: AppSpacing.xxxl * 4,
      child: EmptyState(
        icon: AppLucide.cabinets,
        title: l10n.settingsCabinets,
        message: l10n.comingSoon,
      ),
    );
  }
}

class _CabinetRow extends StatelessWidget {
  const _CabinetRow({required this.cabinet});

  final Cabinet cabinet;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final swatch = _parseColor(cabinet.color) ?? AppColors.textSubtle;

    return AppCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.tapTarget),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: swatch,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: SizedBox(width: AppSpacing.sm, height: AppSpacing.sm),
            ),
            AppGap.horizontal(AppSpacing.sm),
            Expanded(
              child: Text(
                cabinet.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color? _parseColor(String? value) {
  if (value == null || value.isEmpty) return null;
  var hex = value.startsWith('#') ? value.substring(1) : value;
  if (hex.length == 3) {
    hex = hex.split('').map((c) => '$c$c').join();
  }
  if (hex.length != 6) return null;
  final n = int.tryParse(hex, radix: 16);
  if (n == null) return null;
  return Color(0xFF000000 | n);
}
