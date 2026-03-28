import 'dart:math' as math;

class RetirementCalculator {
  RetirementCalculator._();

  static double getReturnRate({required String sector, required int age}) {
    if (sector == 'government' ||
        sector == 'central_govt' ||
        sector == 'state_govt') {
      return 0.085;
    } else if (sector == 'self_employed') {
      return 0.095;
    } else {
      // private sector
      return age < 35 ? 0.10 : 0.09;
    }
  }

  static double calculateProjectedCorpus({
    required double currentCorpus,
    required double monthlyContribution,
    required int yearsToRetirement,
    required double annualReturnRate,
    double stepUpPercent = 0.0,
  }) {
    final double r = annualReturnRate;
    final int years = yearsToRetirement;
    final double annualContrib = monthlyContribution * 12;

    final double fc1 = years > 0
        ? currentCorpus * math.pow(1 + r, years)
        : currentCorpus;

    double fc2 = 0;
    if (stepUpPercent > 0) {
      // Step-up formula: each year's contribution grows by stepUpPercent,
      // then compounded by r for the remaining years.
      for (int i = 0; i < years; i++) {
        final contribForYear = annualContrib * math.pow(1 + stepUpPercent, i);
        // Assuming end of year contributions
        fc2 += contribForYear * math.pow(1 + r, years - i - 1);
      }
    } else {
      fc2 = (r > 0 && years > 0)
          ? annualContrib * ((math.pow(1 + r, years) - 1) / r)
          : annualContrib * years.toDouble();
    }

    return fc1 + fc2;
  }

  static double calculateRequiredCorpus({
    required double monthlyNeedToday,
    required int yearsToRetirement,
    double inflationRate = 0.06,
    int retirementDurationYears = 25,
  }) {
    final inflatedMonthlyNeed =
        monthlyNeedToday * math.pow(1 + inflationRate, yearsToRetirement);
    return inflatedMonthlyNeed * 12 * retirementDurationYears;
  }

  static int calculateReadinessScore({
    required double projectedCorpus,
    required double requiredCorpus,
  }) {
    if (requiredCorpus <= 0) return 0;

    final ratio = projectedCorpus / requiredCorpus;
    double rawScore;
    if (ratio >= 1.0) {
      rawScore = 100;
    } else if (ratio >= 0.8) {
      rawScore = 80 + ((ratio - 0.8) / 0.2) * 20;
    } else if (ratio >= 0.5) {
      rawScore = 50 + ((ratio - 0.5) / 0.3) * 30;
    } else {
      rawScore = ratio * 100;
    }
    return rawScore.clamp(0.0, 100.0).round();
  }
}
