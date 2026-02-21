import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/user_data_service.dart';
import '../../../../shared/models/lifestyle_goal.dart';
import '../../../onboarding/domain/onboarding_state.dart';
import '../../../onboarding/presentation/onboarding_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../domain/dream_planner_state.dart';

final dreamPlannerProvider =
    StateNotifierProvider<DreamPlannerNotifier, DreamPlannerState>((ref) {
      final s = ref.watch(onboardingProvider);
      return DreamPlannerNotifier(ref, s);
    });

class DreamPlannerNotifier extends StateNotifier<DreamPlannerState> {
  final Ref _ref;

  DreamPlannerNotifier(this._ref, dynamic onboardingState)
    : super(const DreamPlannerState()) {
    _init(onboardingState);
  }

  void _init(dynamic s) {
    int age = s.age ?? 30;
    int targetRetirementAge = s.targetRetirementAge;
    if (targetRetirementAge == 0) targetRetirementAge = 60; // fallback

    String tierName = s.selectedTierName.isNotEmpty
        ? s.selectedTierName
        : 'standard';

    // Map existing onboarding Line Items to LifestyleGoals since Dream Planner uses the Freezed model.
    // We default inflation to 6% per item unless otherwise customized.
    List<LifestyleGoal> goals = [];
    if (s.lifestyleLineItems != null && s.lifestyleLineItems.isNotEmpty) {
      for (var item in s.lifestyleLineItems) {
        goals.add(
          LifestyleGoal(
            id: item.label.toLowerCase().replaceAll(' ', '_'),
            category: item.label.toLowerCase().replaceAll(' ', '_'),
            emoji: item.emoji,
            label: item.label,
            monthlyAmountToday: item.monthlyAmount,
            inflationRate: 0.06,
          ),
        );
      }
    }

    _calculateAndEmit(
      age: age,
      targetAge: targetRetirementAge,
      tierName: tierName,
      goals: goals,
      isSaving: false,
    );
  }

  void _calculateAndEmit({
    required int age,
    required int targetAge,
    required String tierName,
    required List<LifestyleGoal> goals,
    required bool isSaving,
  }) {
    int years = targetAge - age;
    if (years <= 0) years = 1;

    double multiplier = pow(1 + 0.06, years).toDouble();

    double totalToday = 0;
    double totalRetirement = 0;

    for (var g in goals) {
      double itemMultiplier = pow(1 + g.inflationRate, years).toDouble();
      totalToday += g.monthlyAmountToday;
      totalRetirement += (g.monthlyAmountToday * itemMultiplier);
    }

    state = DreamPlannerState(
      age: age,
      targetRetirementAge: targetAge,
      tierName: tierName,
      lineItems: goals,
      inflationRate: 0.06,
      inflationMultiplier: multiplier,
      totalMonthlyToday: totalToday,
      totalMonthlyAtRetirement: totalRetirement,
      isSaving: isSaving,
    );
  }

  Future<void> switchTier(
    String newTierName,
    List<LifestyleGoal> defaultGoals,
  ) async {
    _calculateAndEmit(
      age: state.age,
      targetAge: state.targetRetirementAge,
      tierName: newTierName,
      goals: defaultGoals,
      isSaving: state.isSaving,
    );
    await saveToDatabase();
  }

  Future<void> updateLineItem(String categoryId, double newAmount) async {
    final updatedGoals = state.lineItems.map((g) {
      if (g.id == categoryId || g.category == categoryId) {
        return g.copyWith(monthlyAmountToday: newAmount);
      }
      return g;
    }).toList();

    _calculateAndEmit(
      age: state.age,
      targetAge: state.targetRetirementAge,
      tierName: state.tierName,
      goals: updatedGoals,
      isSaving: state.isSaving,
    );

    await saveToDatabase();
  }

  Future<void> saveToDatabase() async {
    // 1. SharedPreferences (Immediate Local Save)
    state = state.copyWith(isSaving: true);
    try {
      final userDataService = await UserDataService.init();
      await userDataService.saveLifestyleGoals(state.lineItems);

      // 2. Sync to Global Onboarding Provider for Dashboard Sync
      final onboardingNotifier = _ref.read(onboardingProvider.notifier);
      // Update the main state string equivalents for dashboard
      onboardingNotifier.updateLineItems(
        state.lineItems.map((g) => _convertToLineItem(g)).toList(),
        state.totalMonthlyToday,
      );

      // 3. Update Supabase
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        // Create the JSONB payload
        final itemsJson = state.lineItems.map((e) => e.toJson()).toList();

        await Supabase.instance.client.from('lifestyle_goals').upsert({
          'user_id': userId,
          'tier_name': state.tierName,
          'monthly_amount': state.totalMonthlyToday,
          'inflation_rate': state.inflationRate,
          'line_items': itemsJson,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // 4. Force calculate Dashboard
      _ref.invalidate(dashboardProvider);
    } catch (e) {
      // Print error or queue retry logic in real app scenario
      debugPrint("DreamPlanner sync error: $e");
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  LifestyleLineItem _convertToLineItem(LifestyleGoal g) {
    return LifestyleLineItem(
      label: g.label,
      emoji: g.emoji,
      monthlyAmount: g.monthlyAmountToday,
    );
  }
}
