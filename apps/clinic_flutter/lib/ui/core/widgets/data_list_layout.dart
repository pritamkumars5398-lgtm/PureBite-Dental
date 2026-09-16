import 'package:flutter/material.dart';

import '../../../core/constants/app_lucide.dart';
import '../../../core/constants/app_spacing.dart';
import 'app_button.dart';
import 'app_gap.dart';
import 'app_page_header.dart';
import 'app_text_field.dart';
import 'feedback.dart';

/// Reusable DentalPin list page shell: header, search, and list body with
/// loading / empty states.
class DataListLayout extends StatelessWidget {
  const DataListLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.searchLabel,
    this.searchController,
    this.onSearchChanged,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.showTitle = false,
    required this.isLoading,
    required this.isEmpty,
    required this.emptyState,
    this.loadingView = const LoadingView(),
    required this.child,
  });

  final String title;
  final String? subtitle;
  final String searchLabel;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final bool showTitle;
  final bool isLoading;
  final bool isEmpty;
  final Widget emptyState;
  final Widget loadingView;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: title,
            subtitle: subtitle,
            showTitle: showTitle,
            actions: [
              if (actionLabel != null)
                AppButton(
                  label: actionLabel!,
                  icon: actionIcon,
                  onPressed: onAction,
                ),
            ],
          ),
          AppTextField(
            label: searchLabel,
            controller: searchController,
            prefixIcon: AppLucide.search,
            onChanged: onSearchChanged,
          ),
          AppGap.md(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return loadingView;
    if (isEmpty) return emptyState;
    return child;
  }
}
