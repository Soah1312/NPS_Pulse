import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/nps_button.dart';
import '../domain/onboarding_state.dart';
import 'onboarding_provider.dart';
import 'widgets/onboarding_progress.dart';
import 'widgets/onboarding_nav_button.dart';
import 'steps/step_1_name_age.dart';
import 'steps/step_2_sector.dart';
import 'steps/step_3_salary.dart';
import 'steps/step_4_nps_data.dart';
import 'steps/step_5_retirement_age.dart';
import 'steps/step_6_lifestyle.dart';

/// Main onboarding screen — controls page transitions and step orchestration.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onContinue() async {
    final state = ref.read(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    if (state.currentStep == OnboardingState.totalSteps) {
      // Final submission
      try {
        await notifier.submitOnboarding();
        if (mounted) {
          context.go('/dashboard/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something went wrong: ${e.toString()}'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      notifier.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onBack() {
    ref.read(onboardingProvider.notifier).previousStep();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onSkipNps() {
    ref.read(onboardingProvider.notifier).skipNpsData();
    ref.read(onboardingProvider.notifier).nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Progress indicator
            OnboardingProgress(currentStep: state.currentStep),

            const SizedBox(height: AppSpacing.sm),

            // Back button (hidden on step 1)
            Align(
              alignment: Alignment.centerLeft,
              child: state.currentStep > 1
                  ? OnboardingBackButton(onTap: _onBack)
                  : const SizedBox(height: 40),
            ),

            // Step pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  Step1NameAge(),
                  Step2Sector(),
                  Step3Salary(),
                  Step4NpsData(),
                  Step5RetirementAge(),
                  Step6Lifestyle(),
                ],
              ),
            ),

            // Continue button
            OnboardingNavButtons(
              canContinue: state.canContinue,
              isLoading: state.isLoading,
              showBackButton: state.currentStep > 1,
              continueLabel: state.currentStep == OnboardingState.totalSteps
                  ? 'Complete Setup →'
                  : 'Continue',
              onContinue: _onContinue,
              onBack: _onBack,
            ),

            // Skip button on step 4 only
            if (state.currentStep == 4)
              Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.screenPadding,
                  right: AppSpacing.screenPadding,
                  bottom: 12,
                ),
                child: NPSButton(
                  label: 'Skip for now →',
                  variant: NPSButtonVariant.ghost,
                  onPressed: _onSkipNps,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
