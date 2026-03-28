import 'package:flutter/foundation.dart';
import '../../../../shared/models/lifestyle_goal.dart';

@immutable
class DreamPlannerState {
  final String tierName;
  final List<LifestyleGoal> lineItems;
  final int age;
  final int targetRetirementAge;
  final double inflationRate;

  final double inflationMultiplier;
  final double totalMonthlyToday;
  final double totalMonthlyAtRetirement;

  final bool isSaving;

  const DreamPlannerState({
    this.tierName = 'essential',
    this.lineItems = const [],
    this.age = 30,
    this.targetRetirementAge = 60,
    this.inflationRate = 0.06,
    this.inflationMultiplier = 1.0,
    this.totalMonthlyToday = 0.0,
    this.totalMonthlyAtRetirement = 0.0,
    this.isSaving = false,
  });

  DreamPlannerState copyWith({
    String? tierName,
    List<LifestyleGoal>? lineItems,
    int? age,
    int? targetRetirementAge,
    double? inflationRate,
    double? inflationMultiplier,
    double? totalMonthlyToday,
    double? totalMonthlyAtRetirement,
    bool? isSaving,
  }) {
    return DreamPlannerState(
      tierName: tierName ?? this.tierName,
      lineItems: lineItems ?? this.lineItems,
      age: age ?? this.age,
      targetRetirementAge: targetRetirementAge ?? this.targetRetirementAge,
      inflationRate: inflationRate ?? this.inflationRate,
      inflationMultiplier: inflationMultiplier ?? this.inflationMultiplier,
      totalMonthlyToday: totalMonthlyToday ?? this.totalMonthlyToday,
      totalMonthlyAtRetirement:
          totalMonthlyAtRetirement ?? this.totalMonthlyAtRetirement,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
