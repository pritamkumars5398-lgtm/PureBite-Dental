import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/models/clinic_staff_user.dart';
import '../../../../domain/models/user.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_gap.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/feedback.dart';
import '../view_models/users_view_model.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key, this.user, this.viewModel});

  final User? user;
  final UsersViewModel? viewModel;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel?.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = widget.viewModel;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppPageHeader(
          title: l10n.settingsUsers,
          subtitle: l10n.settingsUsersDesc,
        ),
        if (viewModel != null)
          ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => _UsersBody(
              l10n: l10n,
              isLoading: viewModel.isLoading,
              error: viewModel.error,
              users: viewModel.users,
            ),
          )
        else if (widget.user == null)
          SizedBox(
            height: AppSpacing.xxxl * 4,
            child: EmptyState(
              icon: AppLucide.people,
              title: l10n.settingsUsers,
              message: l10n.comingSoon,
            ),
          )
        else
          AppCard(
            child: _UserRow(
              firstName: widget.user!.firstName,
              lastName: widget.user!.lastName,
              email: widget.user!.email,
            ),
          ),
      ],
    );
  }
}

class _UsersBody extends StatelessWidget {
  const _UsersBody({
    required this.l10n,
    required this.isLoading,
    required this.error,
    required this.users,
  });

  final AppLocalizations l10n;
  final bool isLoading;
  final String? error;
  final List<ClinicStaffUser> users;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(height: AppSpacing.xxxl * 4, child: LoadingView());
    }
    if (error != null && users.isEmpty) {
      return SizedBox(
        height: AppSpacing.xxxl * 4,
        child: EmptyState(
          icon: AppLucide.people,
          title: l10n.settingsUsers,
          message: error,
        ),
      );
    }
    if (users.isEmpty) {
      return SizedBox(
        height: AppSpacing.xxxl * 4,
        child: EmptyState(icon: AppLucide.people, title: l10n.settingsUsers),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < users.length; i++) ...[
          if (i > 0) AppGap.sm(),
          AppCard(
            child: _UserRow(
              firstName: users[i].firstName,
              lastName: users[i].lastName,
              email: users[i].email,
              role: users[i].role,
              isActive: users[i].isActive,
            ),
          ),
        ],
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.role,
    this.isActive = true,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String? role;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.tapTarget),
      child: Row(
        children: [
          AppAvatar(
            firstName: firstName,
            lastName: lastName,
            size: AppSpacing.xxl,
          ),
          AppGap.horizontal(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fullName(firstName, lastName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                AppGap.xxs(),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall,
                ),
              ],
            ),
          ),
          if (role != null && role!.isNotEmpty) ...[
            AppGap.horizontal(AppSpacing.sm),
            StatusBadge(
              label: role!,
              tone: isActive ? StatusTone.info : StatusTone.neutral,
            ),
          ],
          AppGap.horizontal(AppSpacing.sm),
          const AppIcon(
            icon: AppLucide.chevronRight,
            size: AppIcons.md,
            color: AppColors.textSubtle,
          ),
        ],
      ),
    );
  }
}
