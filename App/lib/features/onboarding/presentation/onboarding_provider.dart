import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/onboarding_state.dart';
import '../../../shared/models/user_profile.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
      (ref) => OnboardingNotifier(),
    );

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  // ── Step Navigation ──────────────────────────────────────

  void goToStep(int step) {
    if (step >= 1 && step <= OnboardingState.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  void nextStep() {
    if (state.currentStep < OnboardingState.totalSteps) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  // ── Step 1 — Name & Age ─────────────────────────────────

  void updateFirstName(String name) {
    state = state.copyWith(firstName: name);
  }

  void updateLastName(String name) {
    state = state.copyWith(lastName: name);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateAge(int? age) {
    state = state.copyWith(age: age);
  }

  // ── Step 2 — Sector ─────────────────────────────────────

  void updateSector(String sector) {
    state = state.copyWith(sector: sector);
  }

  // ── Step 3 — Salary ─────────────────────────────────────

  void updateMonthlySalary(double? salary) {
    state = state.copyWith(monthlySalary: salary);
  }

  // ── Step 4 — NPS Data ───────────────────────────────────

  void updateCurrentCorpus(double? corpus) {
    state = state.copyWith(currentCorpus: corpus);
  }

  void updateMonthlyEmployeeContribution(double? contribution) {
    state = state.copyWith(monthlyEmployeeContribution: contribution);
    if (contribution != null) {
      _updateNpsDataInBg({'monthly_employee_contribution': contribution});
    }
  }

  void updateMonthlyEmployerContribution(double? contribution) {
    state = state.copyWith(monthlyEmployerContribution: contribution);
  }

  void skipNpsData() {
    state = state.copyWith(
      currentCorpus: 0,
      monthlyEmployeeContribution: 0,
      monthlyEmployerContribution: 0,
    );
  }

  // ── Step 5 — Retirement Age ─────────────────────────────

  void updateTargetRetirementAge(int age) {
    state = state.copyWith(targetRetirementAge: age);
    _updateProfileInBg({'target_retirement_age': age});
  }

  // ── Step 6 — Lifestyle Tier ─────────────────────────────

  void selectTier(
    String tierName,
    double monthlyAmount,
    List<LifestyleLineItem> lineItems,
  ) {
    state = state.copyWith(
      selectedTierName: tierName,
      retirementMonthlyAmount: monthlyAmount,
      lifestyleLineItems: lineItems,
    );
  }

  void updateLineItems(List<LifestyleLineItem> lineItems, double newTotal) {
    state = state.copyWith(
      lifestyleLineItems: lineItems,
      retirementMonthlyAmount: newTotal,
    );
  }

  // ── Simulator Settings ──────────────────────────────────

  void updateSimulationSettings({
    bool? stepUpEnabled,
    double? stepUpPercent,
    double? equityAllocation,
  }) {
    state = state.copyWith(
      stepUpEnabled: stepUpEnabled,
      stepUpPercent: stepUpPercent,
      equityAllocation: equityAllocation,
    );

    // Save to Supabase in the background if user is logged in
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final updates = <String, dynamic>{};
      if (stepUpEnabled != null) updates['step_up_enabled'] = stepUpEnabled;
      if (stepUpPercent != null) updates['step_up_percent'] = stepUpPercent;
      if (equityAllocation != null) {
        updates['equity_allocation'] = equityAllocation;
      }

      if (updates.isNotEmpty) {
        _updateNpsDataInBg(updates);
      }
    }
  }

  // ── Database Sync Helpers ───────────────────────────────

  Future<void> _updateProfileInBg(Map<String, dynamic> updates) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', userId);
      debugPrint('Sync success profile: $updates');
    } catch (e) {
      debugPrint('Sync error profile: $e');
    }
  }

  Future<void> _updateNpsDataInBg(Map<String, dynamic> updates) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      updates['last_updated'] = DateTime.now().toIso8601String();
      await Supabase.instance.client
          .from('nps_data')
          .update(updates)
          .eq('user_id', userId);
      debugPrint('Sync success nps_data: $updates');
    } catch (e) {
      debugPrint('Sync error nps_data: $e');
    }
  }

  // ── Data Loading ────────────────────────────────────────

  void populateFromProfile({
    required UserProfile profile,
    required Map<String, dynamic>? npsData,
    required List<Map<String, dynamic>> goals,
  }) {
    final names = profile.name.split(' ');
    final firstName = names.isNotEmpty ? names[0] : '';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    double loadedStepUp =
        (npsData?['step_up_percent'] as num?)?.toDouble() ?? 0.0;
    if (loadedStepUp > 1.0) loadedStepUp /= 100.0;

    double loadedEquity =
        (npsData?['equity_allocation'] as num?)?.toDouble() ?? 0.50;
    if (loadedEquity > 1.0) loadedEquity /= 100.0;

    state = state.copyWith(
      firstName: firstName,
      lastName: lastName,
      age: profile.age,
      sector: profile.sector,
      monthlySalary: profile.monthlySalary,
      targetRetirementAge: profile.targetRetirementAge,
      currentCorpus: (npsData?['current_corpus'] as num?)?.toDouble() ?? 0.0,
      monthlyEmployeeContribution:
          (npsData?['monthly_employee_contribution'] as num?)?.toDouble() ??
          0.0,
      monthlyEmployerContribution:
          (npsData?['monthly_employer_contribution'] as num?)?.toDouble() ??
          0.0,
      stepUpEnabled: npsData?['step_up_enabled'] as bool? ?? false,
      stepUpPercent: loadedStepUp,
      equityAllocation: loadedEquity,
      lifestyleLineItems: goals.map((g) {
        return LifestyleLineItem(
          emoji: '🎯', // Default emoji for loaded goals
          label: (g['category'] as String).replaceAll('_', ' ').toUpperCase(),
          monthlyAmount: (g['monthly_amount_today'] as num).toDouble(),
        );
      }).toList(),
      retirementMonthlyAmount: goals.fold<double>(
        0.0,
        (double sum, dynamic g) =>
            sum + ((g['monthly_amount_today'] as num?)?.toDouble() ?? 0.0),
      ),
      currentStep: 6, // Jump to end or dashboard
    );
  }

  // ── Final Submission ────────────────────────────────────

  Future<void> submitOnboarding() async {
    state = state.copyWith(isLoading: true);

    try {
      final client = Supabase.instance.client;

      // DEBUG: Print current config
      debugPrint('DEBUG: Supabase URL: ${Supabase.instance.client.rest.url}');
      debugPrint('DEBUG: Attempting Anon Login...');

      // 1. Ensure user is authenticated using email and password
      final authRes = await client.auth.signUp(
        email: state.email,
        password: state.password,
      );
      final session = authRes.session;

      final userId = session?.user.id ?? authRes.user?.id ?? '';
      if (userId.isEmpty) throw Exception('Failed to get valid User ID');

      // 2. Save profile
      await client.from('profiles').upsert({
        'id': userId,
        'name': '${state.firstName} ${state.lastName}',
        'age': state.age,
        'gender': 'male',
        'sector': state.sector,
        'monthly_salary': state.monthlySalary,
        'target_retirement_age': state.targetRetirementAge,
        'tax_regime': '',
        'created_at': DateTime.now().toIso8601String(),
      });

      // 3. Save NPS data
      await client.from('nps_data').upsert({
        'user_id': userId,
        'current_corpus': state.currentCorpus ?? 0,
        'monthly_employee_contribution': state.monthlyEmployeeContribution ?? 0,
        'monthly_employer_contribution': state.monthlyEmployerContribution ?? 0,
        'fund_choice': 'auto',
        'last_updated': DateTime.now().toIso8601String(),
      });

      // 4. Save lifestyle tier as goals
      final goalRows = state.lifestyleLineItems
          .map(
            (item) => {
              'user_id': userId,
              'category': item.label.toLowerCase().replaceAll(' ', '_'),
              'monthly_amount_today': item.monthlyAmount,
            },
          )
          .toList();

      if (goalRows.isNotEmpty) {
        await client.from('lifestyle_goals').upsert(goalRows);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}
