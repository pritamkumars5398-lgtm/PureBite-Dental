import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/session.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_card.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_icon.dart';
import '../../../../ui/core/widgets/app_page_header.dart';
import '../view_models/clinic_info_view_model.dart';

class ClinicInfoPage extends StatefulWidget {
  const ClinicInfoPage({super.key, this.session, this.viewModel});

  final Session? session;
  final ClinicInfoViewModel? viewModel;

  @override
  State<ClinicInfoPage> createState() => _ClinicInfoPageState();
}

class _ClinicInfoPageState extends State<ClinicInfoPage> {
  static const _placeholder = '—';

  @override
  void initState() {
    super.initState();
    widget.viewModel?.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    if (vm == null) {
      return _buildBody(context);
    }
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final clinic = widget.viewModel?.clinic;

    final fields = <_ClinicField>[
      _ClinicField(
        label: l10n.settingsClinicInfo,
        value: _clinicName(),
        icon: AppLucide.clinic,
      ),
      _ClinicField(
        label: l10n.patientPhone,
        value: _display(clinic?.phone),
        icon: AppLucide.phone,
      ),
      _ClinicField(
        label: l10n.patientEmail,
        value: _display(clinic?.email),
        icon: AppLucide.mail,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: l10n.settingsClinicInfo,
          subtitle: l10n.settingsClinicInfoDesc,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppIcon(icon: AppLucide.clinic, size: AppIcons.md),
                  AppGap.horizontal(AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.settingsClinicInfo,
                      style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              AppGap.xs(),
              Text(l10n.comingSoon, style: text.labelSmall),
              AppGap.md(),
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumn = constraints.maxWidth >= 600;
                  if (twoColumn) {
                    return _TwoColumnFields(fields: fields);
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < fields.length; i++) ...[
                        if (i > 0) AppGap.md(),
                        _ClinicFieldRow(field: fields[i]),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _clinicName() {
    final fromApi = widget.viewModel?.clinicName ?? '';
    if (fromApi.isNotEmpty) return fromApi;
    final clinic = _selectedClinic(widget.session);
    final fromSession = clinic?.name ?? '';
    if (fromSession.isNotEmpty) return fromSession;
    return _placeholder;
  }

  String _display(String? value) {
    if (value == null || value.isEmpty) return _placeholder;
    return value;
  }

  ClinicMembership? _selectedClinic(Session? session) {
    if (session == null || session.clinics.isEmpty) return null;
    for (final clinic in session.clinics) {
      if (clinic.id == session.selectedClinicId) return clinic;
    }
    return session.clinics.first;
  }
}

class _ClinicField {
  const _ClinicField({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;
}

class _TwoColumnFields extends StatelessWidget {
  const _TwoColumnFields({required this.fields});

  final List<_ClinicField> fields;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < fields.length; i += 2) {
      if (i > 0) rows.add(AppGap.md());
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _ClinicFieldRow(field: fields[i])),
            AppGap.horizontal(AppSpacing.lg),
            Expanded(
              child: i + 1 < fields.length
                  ? _ClinicFieldRow(field: fields[i + 1])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }
    return Column(children: rows);
  }
}

class _ClinicFieldRow extends StatelessWidget {
  const _ClinicFieldRow({required this.field});

  final _ClinicField field;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.icon != null) ...[
          AppIcon(
            icon: field.icon!,
            size: AppIcons.md,
            color: AppColors.textSubtle,
          ),
          AppGap.horizontal(AppSpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.label, style: text.labelSmall),
              AppGap.xxs(),
              Text(
                field.value,
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
