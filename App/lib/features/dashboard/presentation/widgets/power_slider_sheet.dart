import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/retirement_calculator.dart';
import '../../../../shared/widgets/nps_button.dart';
import '../../../../shared/widgets/nps_card.dart';
import '../../../../shared/widgets/rupee_display.dart';
import '../../../../features/onboarding/presentation/onboarding_provider.dart';
import 'readiness_arc_hero.dart';

class PowerSliderSheet extends ConsumerStatefulWidget {
  final double? initialContribution;
  final double? initialStepUp;
  final double? initialEquity;
  final int? initialRetirementAge;

  const PowerSliderSheet({
    super.key,
    this.initialContribution,
    this.initialStepUp,
    this.initialEquity,
    this.initialRetirementAge,
  });

  @override
  ConsumerState<PowerSliderSheet> createState() => _PowerSliderSheetState();
}

class _PowerSliderSheetState extends ConsumerState<PowerSliderSheet> {
  late double _monthlyContribution;
  late bool _stepUpEnabled;
  late double _stepUpPercent;
  late double _equityAllocation;
  late int _targetAge;

  double _baseProjectedCorpus = 0;
  int _baseScore = 0;
  double _currentRequiredCorpus = 0;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final s = ref.read(onboardingProvider);
      final defaultContrib =
          (s.monthlyEmployeeContribution ?? 0.0) +
          (s.monthlyEmployerContribution ?? 0.0);

      _monthlyContribution = widget.initialContribution ?? defaultContrib;
      if (_monthlyContribution <= 0) _monthlyContribution = 5000; // fallback

      _stepUpPercent = widget.initialStepUp ?? s.stepUpPercent;
      _stepUpEnabled = _stepUpPercent > 0 || s.stepUpEnabled;
      if (!_stepUpEnabled && _stepUpPercent <= 0) {
        _stepUpPercent = 0.10; // default when turning on
      }

      _equityAllocation =
          widget.initialEquity ?? s.equityAllocation; // default 50%
      _targetAge = widget.initialRetirementAge ?? s.targetRetirementAge;

      _calculateBaseMetrics(s, defaultContrib);
      _initialized = true;
    }
  }

  void _calculateBaseMetrics(dynamic s, double currentMonthlyContrib) {
    int age = s.age ?? 0;
    if (age == 0) age = 30; // fallback
    int currentTargetAge = s.targetRetirementAge;
    int years = currentTargetAge - age;
    if (years <= 0) years = 1;

    double annualReturn = RetirementCalculator.getReturnRate(
      sector: s.sector ?? '',
      age: age,
    );

    _baseProjectedCorpus = RetirementCalculator.calculateProjectedCorpus(
      currentCorpus: s.currentCorpus ?? 0.0,
      monthlyContribution: currentMonthlyContrib,
      yearsToRetirement: years,
      annualReturnRate: annualReturn,
    );
    _currentRequiredCorpus = RetirementCalculator.calculateRequiredCorpus(
      monthlyNeedToday: s.retirementMonthlyAmount,
      yearsToRetirement: years,
    );
    _baseScore = RetirementCalculator.calculateReadinessScore(
      projectedCorpus: _baseProjectedCorpus,
      requiredCorpus: _currentRequiredCorpus,
    );
  }

  double _getCalculatedSimulatedScore() {
    final s = ref.read(onboardingProvider);
    int age = s.age ?? 0;
    if (age == 0) age = 30;

    int years = _targetAge - age;
    if (years <= 0) years = 1;

    double simulatedReturn = RetirementCalculator.getReturnRate(
      sector: s.sector ?? '',
      age: age,
    );
    if (age < 45 && s.sector != 'central_govt' && _equityAllocation > 0) {
      simulatedReturn = 0.085 + (_equityAllocation / 0.75) * 0.02;
    }

    double proj = RetirementCalculator.calculateProjectedCorpus(
      currentCorpus: s.currentCorpus ?? 0.0,
      monthlyContribution:
          _monthlyContribution + (s.monthlyEmployerContribution ?? 0.0),
      yearsToRetirement: years,
      annualReturnRate: simulatedReturn,
      stepUpPercent: _stepUpEnabled ? _stepUpPercent : 0.0,
    );

    double req = RetirementCalculator.calculateRequiredCorpus(
      monthlyNeedToday: s.retirementMonthlyAmount,
      yearsToRetirement: years,
    );

    return RetirementCalculator.calculateReadinessScore(
      projectedCorpus: proj,
      requiredCorpus: req,
    ).toDouble();
  }

  double _getExtraCorpus() {
    final s = ref.read(onboardingProvider);
    int age = s.age ?? 0;
    if (age == 0) age = 30;
    int years = _targetAge - age;
    if (years <= 0) years = 1;

    double simulatedReturn = RetirementCalculator.getReturnRate(
      sector: s.sector ?? '',
      age: age,
    );
    if (age < 45 && s.sector != 'central_govt' && _equityAllocation > 0) {
      simulatedReturn = 0.085 + (_equityAllocation / 0.75) * 0.02;
    }

    double proj = RetirementCalculator.calculateProjectedCorpus(
      currentCorpus: s.currentCorpus ?? 0.0,
      monthlyContribution:
          _monthlyContribution + (s.monthlyEmployerContribution ?? 0.0),
      yearsToRetirement: years,
      annualReturnRate: simulatedReturn,
      stepUpPercent: _stepUpEnabled ? _stepUpPercent : 0.0,
    );

    double extra = proj - _baseProjectedCorpus;
    return extra > 0 ? extra : 0;
  }

  Color _getEquityColor() {
    if (_equityAllocation <= 0.25) return AppColors.accentBlue;
    if (_equityAllocation <= 0.50) return AppColors.accentAmber;
    return AppColors.success;
  }

  String _getEquityLabel() {
    if (_equityAllocation <= 0.25) return "Conservative";
    if (_equityAllocation <= 0.50) return "Moderate";
    final age = ref.read(onboardingProvider).age ?? 30;
    return "Aggressive — recommended for age $age";
  }

  Color _getScoreColor(int score) {
    if (score >= 86) return AppColors.success;
    if (score >= 71) return const Color(0xFF66BB6A);
    if (score >= 51) return AppColors.accentBlue;
    if (score >= 31) return const Color(0xFFFF7043);
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(onboardingProvider);
    final age = s.age ?? 0;
    final sector = s.sector ?? '';
    final defaultContrib =
        (s.monthlyEmployeeContribution ?? 0.0) +
        (s.monthlyEmployerContribution ?? 0.0);
    final minContrib = defaultContrib > 0 ? defaultContrib : 1000.0;
    final maxContrib = minContrib * 3.0;

    int simulatedScore = _getCalculatedSimulatedScore().round();
    int scoreDiff = simulatedScore - _baseScore;
    double extraCorpus = _getExtraCorpus();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Retirement Simulator',
                      style: AppTypography.headingMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'See how changes affect your readiness',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.borderSubtle, height: 1),

              // SCROLLABLE BODY
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // SECTION A — Contribution
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly Contribution',
                          style: AppTypography.labelLarge,
                        ),
                        RupeeDisplay(
                          amount: _monthlyContribution,
                          size: RupeeDisplaySize.small,
                          color: AppColors.accentAmber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.accentAmber,
                        thumbColor: AppColors.accentAmber,
                        overlayColor: AppColors.accentAmber.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      child: Slider(
                        value: _monthlyContribution.clamp(
                          minContrib,
                          maxContrib,
                        ),
                        min: minContrib,
                        max: maxContrib,
                        divisions: 50,
                        onChanged: (val) =>
                            setState(() => _monthlyContribution = val),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormatter.formatCompact(minContrib),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatCompact(maxContrib),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Extra corpus: +${CurrencyFormatter.formatCompact(extraCorpus)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // SECTION B — Step-Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Annual step-up', style: AppTypography.labelLarge),
                        Switch(
                          value: _stepUpEnabled,
                          activeTrackColor: AppColors.accentAmber,
                          onChanged: (val) =>
                              setState(() => _stepUpEnabled = val),
                        ),
                      ],
                    ),
                    if (_stepUpEnabled) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [0.05, 0.10, 0.15].map((percent) {
                          final isSelected = _stepUpPercent == percent;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _stepUpPercent = percent),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accentAmber
                                      : AppColors.backgroundTertiary,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.accentAmber
                                        : AppColors.borderSubtle,
                                  ),
                                ),
                                child: Text(
                                  '${(percent * 100).toInt()}%',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isSelected
                                        ? AppColors.backgroundPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Your contributions grow with your salary',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // SECTION C — Equity Allocation
                    if (age < 45 && sector != 'central_govt') ...[
                      Text(
                        'Equity Allocation (Active Choice)',
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Higher equity = higher potential returns but more volatility',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: _getEquityColor(),
                          thumbColor: _getEquityColor(),
                          overlayColor: _getEquityColor().withValues(
                            alpha: 0.2,
                          ),
                        ),
                        child: Slider(
                          value: _equityAllocation,
                          min: 0,
                          max: 0.75,
                          divisions: 15,
                          onChanged: (val) =>
                              setState(() => _equityAllocation = val),
                        ),
                      ),
                      Text(
                        _getEquityLabel(),
                        style: AppTypography.bodySmall.copyWith(
                          color: _getEquityColor(),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // SECTION D — Target Age
                    Text(
                      'Target Retirement Age',
                      style: AppTypography.labelLarge,
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [55, 58, 60, 62, 65].map((a) {
                          final isSelected = _targetAge == a;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _targetAge = a),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accentAmber
                                      : AppColors.backgroundTertiary,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.accentAmber
                                        : AppColors.borderSubtle,
                                  ),
                                ),
                                child: Text(
                                  '$a',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isSelected
                                        ? AppColors.backgroundPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_targetAge - age} years to retirement',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // LIVE SCORE PREVIEW (Fixed at bottom)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundPrimary,
                  border: Border(
                    top: BorderSide(color: AppColors.borderMedium),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      NPSCard(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.backgroundSecondary,
                                _getScoreColor(
                                  simulatedScore,
                                ).withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Simulated Score',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(
                                      begin: _baseScore.toDouble(),
                                      end: simulatedScore.toDouble(),
                                    ),
                                    duration: const Duration(milliseconds: 400),
                                    builder: (context, val, child) {
                                      return Text(
                                        val.toInt().toString(),
                                        style: AppTypography.displaySmall
                                            .copyWith(
                                              color: _getScoreColor(
                                                val.toInt(),
                                              ),
                                            ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              if (scoreDiff != 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scoreDiff > 0
                                        ? AppColors.success.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppColors.danger.withValues(
                                            alpha: 0.15,
                                          ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    scoreDiff > 0
                                        ? '+$scoreDiff pts'
                                        : '$scoreDiff pts',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: scoreDiff > 0
                                          ? AppColors.success
                                          : AppColors.danger,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  'No change',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              SizedBox(
                                width: 80,
                                height: 80,
                                // Pass key to force rebuild so arc reanimates, or just let arc handle update
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: _baseScore.toDouble(),
                                    end: simulatedScore.toDouble(),
                                  ),
                                  duration: const Duration(milliseconds: 400),
                                  builder: (context, val, child) {
                                    return AnimatedArcGauge(
                                      progress: (val / 100.0).clamp(0.0, 1.0),
                                      scoreColor: _getScoreColor(val.toInt()),
                                      size: 80,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      NPSButton(
                        label: 'Save Changes',
                        onPressed: () {
                          // Update Onboarding Provider with new values
                          ref.read(onboardingProvider.notifier)
                            ..updateMonthlyEmployeeContribution(
                              _monthlyContribution,
                            )
                            ..updateTargetRetirementAge(_targetAge)
                            ..updateSimulationSettings(
                              stepUpEnabled: _stepUpEnabled,
                              stepUpPercent: _stepUpPercent,
                              equityAllocation: _equityAllocation,
                            );

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Your plan has been updated! 🎯'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Just exploring',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
