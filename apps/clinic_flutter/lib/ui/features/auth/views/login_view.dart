import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/constants/app_breakpoints.dart';
import '../../../../core/constants/app_lucide.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../ui/core/widgets/app_button.dart';
import '../../../../ui/core/widgets/app_gap.dart';
import '../../../../ui/core/widgets/app_text_field.dart';
import '../view_models/login_view_model.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppBreakpoints.contentMax),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                return AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.loginTitle,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      AppGap.xl(),
                      AppTextField(
                        label: l10n.loginEmail,
                        controller: viewModel.emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: AppLucide.mail,
                        textInputAction: TextInputAction.next,
                      ),
                      AppGap.md(),
                      AppTextField(
                        label: l10n.loginPassword,
                        controller: viewModel.passwordController,
                        obscureText: true,
                        prefixIcon: AppLucide.lock,
                        textInputAction: TextInputAction.done,
                      ),
                      if (viewModel.errorCode != null) ...[
                        AppGap.sm(),
                        Text(
                          switch (viewModel.errorCode) {
                            'network' =>
                              viewModel.errorDetail ?? l10n.loginNetworkError,
                            'credentials' => l10n.loginCredentialsError,
                            'tooShort' => l10n.loginPasswordShort,
                            'invalid' => l10n.loginInvalid,
                            _ => viewModel.errorDetail ?? l10n.loginError,
                          },
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.dangerText,
                              ),
                        ),
                      ],
                      AppGap.lg(),
                      AppButton(
                        label: l10n.loginSubmit,
                        loading: viewModel.isLoading,
                        icon: AppLucide.login,
                        onPressed: () async {
                          final ok = await viewModel.submit();
                          if (ok && context.mounted) {
                            // Router redirect watches session.
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
