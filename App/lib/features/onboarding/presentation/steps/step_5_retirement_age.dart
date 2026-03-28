import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../onboarding_provider.dart';

/// Step 5: Retirement Age — large horizontal slider with live display
class Step5RetirementAge extends ConsumerWidget {
  const Step5RetirementAge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final retirementAge = state.targetRetirementAge;
    final currentAge = state.age ?? 25;
    final yearsFromNow = retirementAge - currentAge;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'When do you want\nto retire?',
            style: AppTypography.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'NPS allows withdrawal from age 60. You can plan for earlier partial exit.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl + AppSpacing.xl),

          // Large centered age display
          Center(
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    'Age $retirementAge',
                    key: ValueKey(retirementAge),
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.accentAmber,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$yearsFromNow years from now',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accentAmber,
              inactiveTrackColor: AppColors.borderSubtle,
              thumbColor: Colors.white,
              overlayColor: AppColors.accentAmber.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 3,
              ),
            ),
            child: Slider(
              value: retirementAge.toDouble(),
              min: 45,
              max: 70,
              divisions: 25,
              onChanged: (value) {
                ref
                    .read(onboardingProvider.notifier)
                    .updateTargetRetirementAge(value.round());
              },
            ),
          ),

          // Endpoint labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '45',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '70',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Contextual note
          _RetirementNote(age: retirementAge),
        ],
      ),
    );
  }
}

class _RetirementNote extends StatelessWidget {
  final int age;
  const _RetirementNote({required this.age});

  @override
  Widget build(BuildContext context) {
    String text;
    Color bgColor;
    String icon;

    if (age < 60) {
      text = 'Early exit rules apply — 80% corpus must buy annuity';
      bgColor = AppColors.dangerMuted;
      icon = '⚠️';
    } else if (age == 60) {
      text = 'Standard NPS exit — 60% tax-free lump sum';
      bgColor = AppColors.success.withValues(alpha: 0.15);
      icon = '✅';
    } else {
      text = 'Deferred withdrawal — corpus keeps growing';
      bgColor = AppColors.success.withValues(alpha: 0.15);
      icon = '✅';
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(age < 60 ? 'early' : (age == 60 ? 'standard' : 'defer')),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
