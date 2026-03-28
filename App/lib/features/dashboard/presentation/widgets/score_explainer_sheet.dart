import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/nps_card.dart';
import '../../../../shared/widgets/nps_button.dart';
import '../../../../features/onboarding/presentation/onboarding_provider.dart';
import '../../../../core/utils/retirement_calculator.dart';
import '../providers/dashboard_provider.dart';
import 'power_slider_sheet.dart';

class ScoreExplainerSheet extends ConsumerWidget {
  const ScoreExplainerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(onboardingProvider);
    final dashboard = ref.watch(dashboardProvider);

    final score = dashboard.readinessScore;
    final targetAge = s.targetRetirementAge;
    final tierName = s.selectedTierName.isNotEmpty
        ? s.selectedTierName
        : 'standard';

    final age = s.age ?? 30;
    final sector = s.sector ?? '';
    final returnRate = RetirementCalculator.getReturnRate(
      sector: sector,
      age: age,
    );
    final returnPercent = (returnRate * 100).toStringAsFixed(1);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // HEADER
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderMedium,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Understanding Your Score',
                style: AppTypography.headingMedium,
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.borderSubtle, height: 1),

              // SCROLLABLE BODY
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // SECTION 1: What the score means
                    NPSCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What does $score% mean?',
                              style: AppTypography.headingSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your Retirement Readiness Score shows how well your current NPS savings are projected to fund your chosen retirement lifestyle.\n\nA score of $score% means your projected corpus at age $targetAge will cover $score% of what you'll need for a $tierName retirement.",
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 2: Score scale visual
                    Text('Score Scale', style: AppTypography.headingSmall),
                    const SizedBox(height: 12),
                    _buildBandRow(
                      emoji: '🔴',
                      range: '0-30',
                      label: 'Critical',
                      desc: 'Major gap, immediate action needed',
                      color: AppColors.danger,
                      isCurrent: score >= 0 && score <= 30,
                    ),
                    const SizedBox(height: 8),
                    _buildBandRow(
                      emoji: '🟠',
                      range: '31-50',
                      label: 'At Risk',
                      desc: 'Significant gap, act soon',
                      color: const Color(0xFFFF7043), // Deep Orange
                      isCurrent: score >= 31 && score <= 50,
                    ),
                    const SizedBox(height: 8),
                    _buildBandRow(
                      emoji: '🔵',
                      range: '51-70',
                      label: 'On Track',
                      desc: 'Heading right, keep going',
                      color: AppColors.accentBlue,
                      isCurrent: score >= 51 && score <= 70,
                    ),
                    const SizedBox(height: 8),
                    _buildBandRow(
                      emoji: '🟢',
                      range: '71-85',
                      label: 'Good',
                      desc: 'Minor adjustments needed',
                      color: const Color(0xFF66BB6A), // Light Green
                      isCurrent: score >= 71 && score <= 85,
                    ),
                    const SizedBox(height: 8),
                    _buildBandRow(
                      emoji: '🟢',
                      range: '86-100',
                      label: 'Excellent',
                      desc: 'Well funded, stay consistent',
                      color: AppColors.success,
                      isCurrent: score >= 86,
                    ),
                    const SizedBox(height: 32),

                    // SECTION 3: What 100% actually means
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundTertiary,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadius,
                        ),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Does 100% mean I'm done?",
                            style: AppTypography.headingSmall.copyWith(
                              color: AppColors.accentAmber,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Not quite. 100% means you're on track based on current projections assuming:\n\n"
                            "• $returnPercent% annual investment returns\n"
                            "• 6% annual inflation\n"
                            "• 25 years of retirement after age $targetAge\n\n"
                            "Life is unpredictable — markets fluctuate, expenses change, and you might live longer than expected. A 100% score today is a great sign but not a guarantee.",
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '💡',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Use the Stress Tester (coming soon) to see how your plan holds up in bad market conditions",
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.accentAmber,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // SECTION 4: How to improve
                    Text(
                      "How do I improve my score?",
                      style: AppTypography.headingSmall,
                    ),
                    const SizedBox(height: 12),
                    _buildImproveRow(
                      '📈',
                      'Increase your monthly NPS contribution',
                    ),
                    _buildImproveRow('⏰', 'Give your corpus more time to grow'),
                    _buildImproveRow('🚀', 'Optimize your fund allocation'),
                    const SizedBox(height: 16),
                    NPSButton(
                      label: 'See your personalized action plan →',
                      variant: NPSButtonVariant.secondary,
                      onPressed: () {
                        // Close explainer and open Power Slider
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const PowerSliderSheet(),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // SECTION 5: Honest disclaimer
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "This score is an estimate based on standard assumptions. It is not financial advice. NPS returns depend on market performance and fund allocation. Consult a SEBI-registered financial advisor for personalized guidance.",
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textDisabled,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // CLOSE BUTTON
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  border: Border(
                    top: BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: NPSButton(
                    label: 'Got it',
                    variant: NPSButtonVariant.ghost,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBandRow({
    required String emoji,
    required String range,
    required String label,
    required String desc,
    required Color color,
    required bool isCurrent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.backgroundTertiary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent
            ? Border(left: BorderSide(color: color, width: 3))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          SizedBox(
            width: 50,
            child: Text(
              range,
              style: AppTypography.labelSmall.copyWith(
                color: isCurrent ? Colors.white : AppColors.textSecondary,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isCurrent ? color : AppColors.textSecondary,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              desc,
              style: AppTypography.bodySmall.copyWith(
                color: isCurrent
                    ? AppColors.textPrimary
                    : AppColors.textDisabled,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImproveRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(text, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
