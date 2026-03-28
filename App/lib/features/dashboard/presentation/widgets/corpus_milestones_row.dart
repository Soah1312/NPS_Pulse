import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/retirement_calculator.dart';
import '../../../../features/onboarding/presentation/onboarding_provider.dart';

class MilestoneData {
  final double amount;
  final int ageReached;
  final bool isPassed;

  MilestoneData({
    required this.amount,
    required this.ageReached,
    required this.isPassed,
  });
}

class CorpusMilestonesRow extends ConsumerStatefulWidget {
  const CorpusMilestonesRow({super.key});

  @override
  ConsumerState<CorpusMilestonesRow> createState() =>
      _CorpusMilestonesRowState();
}

class _CorpusMilestonesRowState extends ConsumerState<CorpusMilestonesRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<MilestoneData> _calculateMilestones(WidgetRef ref) {
    final s = ref.watch(onboardingProvider);
    final age = s.age ?? 0;
    final retirementAge = s.targetRetirementAge;
    final currentCorpus = s.currentCorpus ?? 0.0;
    final monthlyContrib =
        (s.monthlyEmployeeContribution ?? 0.0) +
        (s.monthlyEmployerContribution ?? 0.0);
    final sector = s.sector ?? '';

    if (age == 0 || monthlyContrib == 0) return [];

    final r = RetirementCalculator.getReturnRate(sector: sector, age: age);

    final targets = [
      500000.0,
      1000000.0,
      2500000.0,
      5000000.0,
      10000000.0,
      25000000.0,
      50000000.0,
    ];

    List<MilestoneData> milestones = [];
    int maxYears = retirementAge - age;

    for (var target in targets) {
      if (currentCorpus >= target) {
        milestones.add(
          MilestoneData(amount: target, ageReached: age, isPassed: true),
        );
        continue;
      }

      // Find the year it crosses
      for (int y = 1; y <= maxYears; y++) {
        final projected = RetirementCalculator.calculateProjectedCorpus(
          currentCorpus: currentCorpus,
          monthlyContribution: monthlyContrib,
          yearsToRetirement: y,
          annualReturnRate: r,
        );
        if (projected >= target) {
          milestones.add(
            MilestoneData(amount: target, ageReached: age + y, isPassed: false),
          );
          break;
        }
      }
    }

    // Filter to only include milestones with ageReached <= retirementAge
    var valid = milestones.where((m) => m.ageReached <= retirementAge).toList();

    valid.sort((a, b) => a.amount.compareTo(b.amount));

    // Take the last passed and the upcoming ones
    final passedCount = valid.where((m) => m.isPassed).length;
    int startIndex = 0;
    if (passedCount > 1) {
      // Just keep the highest passed one
      startIndex = passedCount - 1;
    }

    var result = valid.sublist(startIndex);
    if (result.length > 5) {
      result = result.sublist(0, 5);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final milestones = _calculateMilestones(ref);
    if (milestones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.borderMedium, height: 1),
        const SizedBox(height: 16),
        Text(
          'Corpus milestones',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(milestones.length, (index) {
              final m = milestones[index];

              // staggered animation
              final start = (index * 0.1).clamp(0.0, 1.0);
              final end = (start + 0.5).clamp(0.0, 1.0);

              final slideAnim =
                  Tween<Offset>(
                    begin: const Offset(0.5, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: Interval(start, end, curve: Curves.easeOutCubic),
                    ),
                  );
              final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animController,
                  curve: Interval(start, end, curve: Curves.easeOutCubic),
                ),
              );

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FadeTransition(
                  opacity: fadeAnim,
                  child: SlideTransition(
                    position: slideAnim,
                    child: _buildChip(m),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(MilestoneData m) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        border: Border.all(
          color: m.isPassed ? AppColors.success : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (m.isPassed) ...[
                const Text(
                  '✓ ',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              Text(
                CurrencyFormatter.formatCompact(m.amount),
                style: AppTypography.labelSmall.copyWith(
                  color: m.isPassed ? AppColors.success : AppColors.accentAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'at age ${m.ageReached}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
