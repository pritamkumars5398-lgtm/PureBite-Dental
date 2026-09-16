import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/core/widgets/app_button.dart';
import '../../../../ui/core/widgets/app_card.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_icon.dart';
import '../../../../ui/core/widgets/app_text_field.dart';
import '../../../../ui/core/widgets/feedback.dart';
import '../view_models/copilot_view_model.dart';

class CopilotView extends StatefulWidget {
  const CopilotView({
    super.key,
    this.viewModel,
    this.messages = const [],
    this.isLoading = false,
    this.onSend,
  });

  final CopilotViewModel? viewModel;
  final List<String> messages;
  final bool isLoading;
  final ValueChanged<String>? onSend;

  @override
  State<CopilotView> createState() => _CopilotViewState();
}

class _CopilotViewState extends State<CopilotView> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel?.load();
  }

  @override
  void didUpdateWidget(covariant CopilotView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewModel != null && widget.viewModel != oldWidget.viewModel) {
      widget.viewModel!.load();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final viewModel = widget.viewModel;
    if (viewModel != null) {
      viewModel.send(text);
    } else {
      widget.onSend?.call(text);
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    if (viewModel == null) {
      return _buildScaffold(
        messages: widget.messages,
        isLoading: widget.isLoading,
        isSending: widget.isLoading,
        canSend: widget.onSend != null,
      );
    }

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return _buildScaffold(
          messages: viewModel.messages,
          isLoading: viewModel.isLoading,
          isSending: viewModel.isSending,
          canSend: true,
        );
      },
    );
  }

  Widget _buildScaffold({
    required List<String> messages,
    required bool isLoading,
    required bool isSending,
    required bool canSend,
  }) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildBody(l10n, messages, isLoading)),
          if (canSend) ...[
            AppGap.md(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AppTextField(
                    label: l10n.notesHint,
                    controller: _controller,
                    prefixIcon: AppLucide.ai,
                    textInputAction: TextInputAction.send,
                  ),
                ),
                AppGap.horizontal(AppSpacing.sm),
                AppButton(
                  label: l10n.notesAdd,
                  icon: AppLucide.plus,
                  loading: isSending,
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(
    AppLocalizations l10n,
    List<String> messages,
    bool isLoading,
  ) {
    if (isLoading && messages.isEmpty) return const LoadingView();
    if (messages.isEmpty) {
      return EmptyState(
        icon: AppLucide.ai,
        title: l10n.aiTitle,
        message: l10n.aiEmpty,
      );
    }
    return ListView.separated(
      itemCount: messages.length,
      separatorBuilder: (_, _) => AppGap.sm(),
      itemBuilder: (context, index) {
        final message = messages[index];
        return AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppIcon(
                icon: AppLucide.ai,
                size: AppIcons.md,
              ),
              AppGap.horizontal(AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
