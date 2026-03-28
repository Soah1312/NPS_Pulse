import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/nps_button.dart';

/// Continue and Back buttons for onboarding flow.
class OnboardingNavButtons extends StatelessWidget {
  final bool canContinue;
  final bool isLoading;
  final bool showBackButton;
  final String continueLabel;
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const OnboardingNavButtons({
    super.key,
    required this.canContinue,
    this.isLoading = false,
    this.showBackButton = true,
    this.continueLabel = 'Continue',
    required this.onContinue,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        bottom:
            MediaQuery.of(context).padding.bottom + AppSpacing.screenPadding,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: NPSButton(
          key: ValueKey(continueLabel),
          label: continueLabel,
          onPressed: canContinue ? onContinue : () {},
          isLoading: isLoading,
          variant: canContinue
              ? NPSButtonVariant.primary
              : NPSButtonVariant.primary,
        ),
      ),
    );
  }
}

/// Top-left back button for onboarding (hidden on step 1).
class OnboardingBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const OnboardingBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.screenPadding, top: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_back_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Back',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
