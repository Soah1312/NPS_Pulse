import 'package:flutter/foundation.dart';

/// Lifestyle line item for tier customization.
@immutable
class LifestyleLineItem {
  final String emoji;
  final String label;
  final double monthlyAmount;
  final int? tripsPerYear;

  const LifestyleLineItem({
    required this.emoji,
    required this.label,
    required this.monthlyAmount,
    this.tripsPerYear,
  });

  LifestyleLineItem copyWith({double? monthlyAmount, int? tripsPerYear}) {
    return LifestyleLineItem(
      emoji: emoji,
      label: label,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      tripsPerYear: tripsPerYear ?? this.tripsPerYear,
    );
  }
}

/// Holds all data collected during the onboarding flow.
@immutable
class OnboardingState {
  // Step tracking
  final int currentStep;
  final bool isLoading;

  // Step 1 — Name & Age
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final int? age;

  // Step 2 — Sector
  final String? sector;

  // Step 3 — Salary
  final double? monthlySalary;

  // Step 4 — NPS Data
  final double? currentCorpus;
  final double? monthlyEmployeeContribution;
  final double? monthlyEmployerContribution;

  // Step 5 — Retirement Age
  final int targetRetirementAge;

  // Step 6 — Lifestyle Tier
  final String selectedTierName; // 'essential' | 'comfortable' | 'lavish'
  final double retirementMonthlyAmount;
  final List<LifestyleLineItem> lifestyleLineItems;

  // Simulator Settings
  final bool stepUpEnabled;
  final double stepUpPercent;
  final double equityAllocation;

  const OnboardingState({
    this.currentStep = 1,
    this.isLoading = false,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.age,
    this.sector,
    this.monthlySalary,
    this.currentCorpus,
    this.monthlyEmployeeContribution,
    this.monthlyEmployerContribution,
    this.targetRetirementAge = 60,
    this.selectedTierName = 'comfortable',
    this.retirementMonthlyAmount = 120000,
    this.lifestyleLineItems = const [],
    this.stepUpEnabled = false,
    this.stepUpPercent = 0.0,
    this.equityAllocation = 0.50,
  });

  OnboardingState copyWith({
    int? currentStep,
    bool? isLoading,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    int? age,
    String? sector,
    double? monthlySalary,
    double? currentCorpus,
    double? monthlyEmployeeContribution,
    double? monthlyEmployerContribution,
    int? targetRetirementAge,
    String? selectedTierName,
    double? retirementMonthlyAmount,
    List<LifestyleLineItem>? lifestyleLineItems,
    bool? stepUpEnabled,
    double? stepUpPercent,
    double? equityAllocation,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      sector: sector ?? this.sector,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      currentCorpus: currentCorpus ?? this.currentCorpus,
      monthlyEmployeeContribution:
          monthlyEmployeeContribution ?? this.monthlyEmployeeContribution,
      monthlyEmployerContribution:
          monthlyEmployerContribution ?? this.monthlyEmployerContribution,
      targetRetirementAge: targetRetirementAge ?? this.targetRetirementAge,
      selectedTierName: selectedTierName ?? this.selectedTierName,
      retirementMonthlyAmount:
          retirementMonthlyAmount ?? this.retirementMonthlyAmount,
      lifestyleLineItems: lifestyleLineItems ?? this.lifestyleLineItems,
      stepUpEnabled: stepUpEnabled ?? this.stepUpEnabled,
      stepUpPercent: stepUpPercent ?? this.stepUpPercent,
      equityAllocation: equityAllocation ?? this.equityAllocation,
    );
  }

  /// Whether the current step's data is valid for proceeding
  bool get canContinue {
    switch (currentStep) {
      case 1:
        final emailValid = RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(email);
        return firstName.trim().length >= 2 &&
            lastName.trim().length >= 2 &&
            emailValid &&
            password.length >= 6 &&
            age != null &&
            age! >= 18 &&
            age! <= 55;
      case 2:
        return sector != null;
      case 3:
        return monthlySalary != null &&
            monthlySalary! >= 10000 &&
            monthlySalary! <= 50000000;
      case 4:
        return currentCorpus != null && monthlyEmployeeContribution != null;
      case 5:
        return true; // slider always has a value
      case 6:
        return selectedTierName.isNotEmpty; // pre-selected, always true
      default:
        return false;
    }
  }

  /// Total number of onboarding steps (was 7, now 6 — no tax regime step)
  static const int totalSteps = 6;
}
