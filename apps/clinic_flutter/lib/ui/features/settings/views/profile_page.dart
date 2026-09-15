import 'package:flutter/material.dart';

import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/models/user.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_gap.dart';
import '../../../core/widgets/app_section_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppSectionCard(
          title: l10n.settingsProfile,
          icon: AppLucide.profile,
          child: user == null
              ? const SizedBox.shrink()
              : Row(
                  children: [
                    AppAvatar(
                      firstName: user!.firstName,
                      lastName: user!.lastName,
                      size: AppSpacing.xxxl,
                    ),
                    AppGap.horizontal(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName(user!.firstName, user!.lastName),
                            style: text.labelMedium,
                          ),
                          AppGap.xxs(),
                          Text(user!.email, style: text.labelSmall),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
