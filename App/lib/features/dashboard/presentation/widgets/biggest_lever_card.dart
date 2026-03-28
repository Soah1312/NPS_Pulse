import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/retirement_calculator.dart';
import '../../../../shared/widgets/nps_button.dart';
import '../../../../features/onboarding/presentation/onboarding_provider.dart';
import 'power_slider_sheet.dart';

class BiggestLeverCard extends ConsumerStatefulWidget {
  const BiggestLeverCard({super.key});

  @override
  ConsumerState<BiggestLeverCard> createState() => _BiggestLeverCardState();
}

class _BiggestLeverCardState extends ConsumerState<BiggestLeverCard> {
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

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(onboardingProvider);
    final age = s.age ?? 0;
    final currentTargetAge = s.targetRetirementAge;
    final years = (currentTargetAge - age) > 0 ? (currentTargetAge - age) : 1;
    final currentCorpus = s.currentCorpus ?? 0.0;
    final currentContrib =
        (s.monthlyEmployeeContribution ?? 0.0) +
        (s.monthlyEmployerContribution ?? 0.0);
    final sector = s.sector ?? '';

    if (age == 0 || currentContrib == 0) return const SizedBox.shrink();

    final r = RetirementCalculator.getReturnRate(sector: sector, age: age);
    final req = RetirementCalculator.calculateRequiredCorpus(
      monthlyNeedToday: s.retirementMonthlyAmount,
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

    if (baseScore >= 100) return const SizedBox.shrink();

    // Option A:
    final projA = RetirementCalculator.calculateProjectedCorpus(
      currentCorpus: currentCorpus,
      monthlyContribution: currentContrib + 2000,
      yearsToRetirement: years,
      annualReturnRate: r,
    );
    final scoreA = RetirementCalculator.calculateReadinessScore(
      projectedCorpus: projA,
      requiredCorpus: req,
    );
    final impactA = scoreA - baseScore;
    final extraA = projA - baseProj;

    // Option B:
    int impactB = -1;
    double extraB = 0;
    if (age < 45 && sector != 'central_govt') {
      final rEquity = 0.085 + (0.75 / 0.75) * 0.02; // 0.105
      final projB = RetirementCalculator.calculateProjectedCorpus(
        currentCorpus: currentCorpus,
        monthlyContribution: currentContrib,
        yearsToRetirement: years,
        annualReturnRate: rEquity,
      );
      final scoreB = RetirementCalculator.calculateReadinessScore(
        projectedCorpus: projB,
        requiredCorpus: req,
      );
      impactB = scoreB - baseScore;
      extraB = projB - baseProj;
    }

    // Option C:
    final projC = RetirementCalculator.calculateProjectedCorpus(
      currentCorpus: currentCorpus,
      monthlyContribution: currentContrib,
      yearsToRetirement: years,
      annualReturnRate: r,
      stepUpPercent: 0.10,
    );
    final scoreC = RetirementCalculator.calculateReadinessScore(
      projectedCorpus: projC,
      requiredCorpus: req,
    );
    final impactC = scoreC - baseScore;
    final extraC = projC - baseProj;

    // Option D:
    final years2 = years + 2;
    final reqD = RetirementCalculator.calculateRequiredCorpus(
      monthlyNeedToday: s.retirementMonthlyAmount,
      yearsToRetirement: years2,
    );
    final projD = RetirementCalculator.calculateProjectedCorpus(
      currentCorpus: currentCorpus,
      monthlyContribution: currentContrib,
      yearsToRetirement: years2,
      annualReturnRate: r,
    );
    final scoreD = RetirementCalculator.calculateReadinessScore(
      projectedCorpus: projD,
      requiredCorpus: reqD,
    );
    final impactD = scoreD - baseScore;

    // Find max impact
    int maxImpact = impactA;
    String title = "Adding ₹2,000/month to your NPS";
    String detail =
        "Increases your score by $impactA points and adds ${CurrencyFormatter.formatCompact(extraA)} to your corpus";
    VoidCallback onAct = () =>
        _openSheet(context, contrib: currentContrib + 2000);

    if (impactB > maxImpact) {
      maxImpact = impactB;
      title = "Switching to Active choice, 75% equity";
      detail =
          "Higher equity allocation at your age could add ${CurrencyFormatter.formatCompact(extraB)} over $years years";
      onAct = () => _openSheet(context, equity: 0.75);
    }
    if (impactC > maxImpact) {
      maxImpact = impactC;
      title = "Setting up a 10% annual step-up plan";
      detail =
          "Increasing contributions with your salary can add ${CurrencyFormatter.formatCompact(extraC)} to your corpus";
      onAct = () => _openSheet(context, stepUp: 0.10);
    }
    if (impactD > maxImpact) {
      maxImpact = impactD;
      title =
          "Retiring at ${currentTargetAge + 2} instead of $currentTargetAge";
      detail =
          "2 more years of contributions and compounding adds $impactD points to your score";
      onAct = () => _openSheet(context, retAge: currentTargetAge + 2);
    }

    if (maxImpact <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppColors.accentAmber.withValues(alpha: 0.5),
              AppColors.accentBlue.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundPrimary,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '⚡ Your Biggest Lever',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.accentAmber,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: maxImpact),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, val, child) {
                        return Text(
                          '+$val pts',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(title, style: AppTypography.headingSmall),
              const SizedBox(height: 8),
              Text(
                detail,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: NPSButton(
                  label: "Take Action →",
                  variant: NPSButtonVariant.secondary,
                  isFullWidth: false, // Keep it compact
                  onPressed: onAct,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
