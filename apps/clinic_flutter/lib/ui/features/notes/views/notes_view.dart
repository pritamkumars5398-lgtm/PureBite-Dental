import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../ui/core/widgets/app_button.dart';
import '../../../../ui/core/widgets/app_card.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_text_field.dart';
import '../../../../ui/core/widgets/feedback.dart';
import '../view_models/notes_view_model.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key, required this.viewModel});

  final NotesViewModel viewModel;

  String _formatTimestamp(DateTime dateTime) {
    final d = dateTime.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.notesTitle,
                style: text.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              AppGap.md(),
              AppTextField(
                label: l10n.notesHint,
                controller: viewModel.controller,
                prefixIcon: LucideIcons.stickyNote,
              ),
              AppGap.sm(),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  label: l10n.notesAdd,
                  icon: LucideIcons.plus,
                  onPressed: viewModel.addNote,
                ),
              ),
              AppGap.md(),
              Expanded(
                child: viewModel.notes.isEmpty
                    ? EmptyState(
                        icon: LucideIcons.stickyNote,
                        title: l10n.notesEmpty,
                      )
                    : ListView.separated(
                        itemCount: viewModel.notes.length,
                        separatorBuilder: (_, _) => AppGap.sm(),
                        itemBuilder: (context, index) {
                          final note = viewModel.notes[index];
                          return AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(note.body, style: text.bodyMedium),
                                AppGap.xs(),
                                Text(
                                  _formatTimestamp(note.createdAt),
                                  style: text.labelSmall,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
