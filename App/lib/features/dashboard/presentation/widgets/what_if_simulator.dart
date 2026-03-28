import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/retirement_calculator.dart';
import '../../../../shared/widgets/nps_card.dart';
import '../../../../features/onboarding/presentation/onboarding_provider.dart';
import 'power_slider_sheet.dart';

class WhatIfScenario {
  final String emoji;
  final String description;
  final int impact;
  final VoidCallback onTap;

  WhatIfScenario({
    required this.emoji,
    required this.description,
    required this.impact,
    required this.onTap,
  });
}

class WhatIfSimulator extends ConsumerStatefulWidget {
  const WhatIfSimulator({super.key});

  @override
  ConsumerState<WhatIfSimulator> createState() => _WhatIfSimulatorState();
}

class _WhatIfSimulatorState extends ConsumerState<WhatIfSimulator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openSheet(
    BuildContext context, {
    double? contrib,
    double? stepUp,
    double? equity,
    int? retAge,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PowerSliderSheet(
        initialContribution: contrib,
        initialStepUp: stepUp,
        initialEquity: equity,
        initialRetirementAge: retAge,
      ),
    );
  }

  List<WhatIfScenario> _buildScenarios(WidgetRef ref, BuildContext context) {
    final s = ref.watch(onboardingProvider);
    final age = s.age ?? 0;
    final currentTargetAge = s.targetRetirementAge;
    final years = (currentTargetAge - age) > 0 ? (currentTargetAge - age) : 1;
    final currentCorpus = s.currentCorpus ?? 0.0;
    final currentContrib =
        (s.monthlyEmployeeContribution ?? 0.0) +
        (s.monthlyEmployerContribution ?? 0.0);
    final sector = s.sector ?? '';
    final monthlyNeed = s.retirementMonthlyAmount;
    final currentTier = s.selectedTierName;

    if (age == 0 || currentContrib == 0) return [];

    final r = RetirementCalculator.getReturnRate(sector: sector, age: age);
    final req = RetirementCalculator.calculateRequiredCorpus(
      monthlyNeedToday: monthlyNeed,
      yearsToRetirement: years,
    );
    final baseProj = RetirementCalculator.calculateProjectedCorpus(
      currentCorpus: currentCorpus,
      monthlyContribution: currentContrib,
      yearsToRetirement: years,
      annualReturnRate: r,
    );
    final baseScore = RetirementCalculator.calculateReadinessScore(
      projectedCorpus: baseProj,
      requiredCorpus: req,
    );

    if (baseScore >= 100) return [];

    List<WhatIfScenario> scenarios = [];

    // ROW 1 — Increase contribution
    final proj1 = RetirementCalculator.calculateProjectedCorpus(
      currentCorpus: currentCorpus,
      monthlyContribution: currentContrib + 2000,
      yearsToRetirement: years,
      annualReturnRate: r,
    );
    final score1 = RetirementCalculator.calculateReadinessScore(
      projectedCorpus: proj1,
      requiredCorpus: req,
    );
    if (score1 > baseScore) {
      scenarios.add(
        WhatIfScenario(
          emoji: '📈',
          description: 'Added ₹2,000/month more',
          impact: score1 - baseScore,
          onTap: () => _openSheet(context, contrib: currentContrib + 2000),
        ),
      );
    }

    // ROW 2 — Step-up plan
    final proj2 = RetirementCalculator.calculateProjectedCorpus(
      currentCorpus: currentCorpus,
      monthlyContribution: currentContrib,
      yearsToRetirement: years,
      annualReturnRate: r,
      stepUpPercent: 0.10,
    );
    final score2 = RetirementCalculator.calculateReadinessScore(
      projectedCorpus: proj2,
      requiredCorpus: req,
    );
    if (score2 > baseScore) {
      scenarios.add(
        WhatIfScenario(
          emoji: '🪜',
          description: 'Did 10% annual step-up',
          impact: score2 - baseScore,
          onTap: () => _openSheet(context, stepUp: 0.10),
        ),
      );
    }

    // ROW 3 — Higher equity
    if (age < 45 && sector != 'central_govt') {
      final rEq = 0.085 + (0.75 / 0.75) * 0.02; // 10.5%
      final proj3 = RetirementCalculator.calculateProjectedCorpus(
        currentCorpus: currentCorpus,
        monthlyContribution: currentContrib,
        yearsToRetirement: years,
        annualReturnRate: rEq,
      );
      final score3 = RetirementCalculator.calculateReadinessScore(
        projectedCorpus: proj3,
        requiredCorpus: req,
      );
      if (score3 > baseScore) {
        scenarios.add(
          WhatIfScenario(
            emoji: '🚀',
            description: 'Switched to 75% equity',
            impact: score3 - baseScore,
            onTap: () => _openSheet(context, equity: 0.75),
          ),
        );
      }
    }

    // ROW 4 — Later retirement
    final req4 = RetirementCalculator.calculateRequiredCorpus(
      monthlyNeedToday: monthlyNeed,
      yearsToRetirement: years + 2,
    );
    final proj4 = RetirementCalculator.calculateProjectedCorpus(
      currentCorpus: currentCorpus,
      monthlyContribution: currentContrib,
      yearsToRetirement: years + 2,
      annualReturnRate: r,
    );
    final score4 = RetirementCalculator.calculateReadinessScore(
      projectedCorpus: proj4,
      requiredCorpus: req4,
    );
    if (score4 > baseScore) {
      scenarios.add(
        WhatIfScenario(
          emoji: '⏰',
          description: 'Retired at ${currentTargetAge + 2} instead',
          impact: score4 - baseScore,
          onTap: () => _openSheet(context, retAge: currentTargetAge + 2),
        ),
      );
    }

    // ROW 5 — Lump sum top-up
    final proj5 = RetirementCalculator.calculateProjectedCorpus(
      currentCorpus: currentCorpus + 50000,
      monthlyContribution: currentContrib,
      yearsToRetirement: years,
      annualReturnRate: r,
    );
    final score5 = RetirementCalculator.calculateReadinessScore(
      projectedCorpus: proj5,
      requiredCorpus: req,
    );
    if (score5 > baseScore) {
      scenarios.add(
        WhatIfScenario(
          emoji: '💰',
          description: 'Added ₹50,000 lump sum today',
          impact: score5 - baseScore,
          onTap: () =>
              _openSheet(context), // Sheet doesn't have lump sum, just open it
        ),
      );
    }

    // ROW 6 — Lifestyle adjustment
    if (currentTier != 'essential') {
      // rough essential tier proxy: half of current amount if standard/premium, or maybe just fixed 40k.
      // Without exact rules, let's say essential is 40,000 or (monthlyNeed * 0.6)
      final essentialNeed = monthlyNeed > 60000 ? monthlyNeed * 0.6 : 40000.0;
      final req6 = RetirementCalculator.calculateRequiredCorpus(
        monthlyNeedToday: essentialNeed,
        yearsToRetirement: years,
      );
      final score6 = RetirementCalculator.calculateReadinessScore(
        projectedCorpus: baseProj,
        requiredCorpus: req6,
      );
      if (score6 > baseScore) {
        scenarios.add(
          WhatIfScenario(
            emoji: '🏡',
            description: 'Switched to Essential lifestyle',
            impact: score6 - baseScore,
            onTap: () => _openSheet(context),
          ),
        );
      }
    }

    return scenarios;
  }

  @override
  Widget build(BuildContext context) {
    final scenarios = _buildScenarios(ref, context);
    if (scenarios.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What If You...', style: AppTypography.headingSmall),
          const SizedBox(height: 4),
          Text(
            'Tap any scenario to see the impact',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.accentAmber,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(scenarios.length, (index) {
            final s = scenarios[index];

            // Staggered fade+slide 150ms stagger, 300ms duration map to overall 1200ms anim controller
            final staggerStart = (index * 0.15).clamp(0.0, 1.0);
            final staggerEnd = (staggerStart + 0.25).clamp(0.0, 1.0);
            final anim = CurvedAnimation(
              parent: _animController,
              curve: Interval(
                staggerStart,
                staggerEnd,
                curve: Curves.easeOutCubic,
              ),
            );

            final fadeAnim = Tween<double>(begin: 0, end: 1).animate(anim);
            final slideAnim = Tween<Offset>(
              begin: const Offset(0, 0.4),
              end: Offset.zero,
            ).animate(anim);

            Color bg;
            Color txtColor;
            if (s.impact >= 10) {
              bg = AppColors.success.withValues(alpha: 0.15);
              txtColor = AppColors.success;
            } else if (s.impact >= 5) {
              bg = AppColors.accentAmber.withValues(alpha: 0.20);
              txtColor = AppColors.accentAmber;
            } else {
              bg = AppColors.backgroundTertiary;
              txtColor = AppColors.textSecondary;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: FadeTransition(
                opacity: fadeAnim,
                child: SlideTransition(
                  position: slideAnim,
                  child: GestureDetector(
                    onTap: s.onTap,
                    child: NPSCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  s.emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(
                                  s.description,
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '+${s.impact} pts',
                                style: s.impact >= 10
                                    ? AppTypography.labelSmall.copyWith(
                                        color: txtColor,
                                        fontWeight: FontWeight.bold,
                                      )
                                    : AppTypography.labelSmall.copyWith(
                                        color: txtColor,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
