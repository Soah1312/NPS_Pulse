import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../../onboarding/presentation/onboarding_provider.dart';

// ─────────────────────────────────────────────────────────────
// Local State for Other Investments
// ─────────────────────────────────────────────────────────────

class TaxShieldLocalState {
  final double otherSection80CInvestments;
  final bool hasEnteredOtherInvestments;

  const TaxShieldLocalState({
    this.otherSection80CInvestments = 0.0,
    this.hasEnteredOtherInvestments = false,
  });

  TaxShieldLocalState copyWith({
    double? otherSection80CInvestments,
    bool? hasEnteredOtherInvestments,
  }) {
    return TaxShieldLocalState(
      otherSection80CInvestments:
          otherSection80CInvestments ?? this.otherSection80CInvestments,
      hasEnteredOtherInvestments:
          hasEnteredOtherInvestments ?? this.hasEnteredOtherInvestments,
    );
  }
}

class TaxShieldLocalNotifier extends StateNotifier<TaxShieldLocalState> {
  TaxShieldLocalNotifier() : super(const TaxShieldLocalState()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final hasEntered = prefs.getBool('hasEnteredOtherInvestments') ?? false;
    final other80C = prefs.getDouble('otherSection80CInvestments') ?? 0.0;
    state = TaxShieldLocalState(
      hasEnteredOtherInvestments: hasEntered,
      otherSection80CInvestments: other80C,
    );
  }

  Future<void> updateOther80C(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('otherSection80CInvestments', amount);
    await prefs.setBool('hasEnteredOtherInvestments', true);
    state = state.copyWith(
      otherSection80CInvestments: amount,
      hasEnteredOtherInvestments: true,
    );
  }

  Future<void> updateTaxRegime(String newRegime, WidgetRef ref) async {
    final authState = ref.read(authProvider).value;
    if (authState == null) return;

    // Save to SharedPreferences for quick client cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('taxRegime', newRegime);

    // Update Supabase
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'tax_regime': newRegime})
          .eq('id', authState.id);

      // Reload auth cache so that the entire tree structurally adapts
      await ref.read(authProvider.notifier).reloadProfile();
    } catch (e) {
      // Intentionally silented in production
    }
  }
}

final taxShieldLocalProvider =
    StateNotifierProvider<TaxShieldLocalNotifier, TaxShieldLocalState>((ref) {
      return TaxShieldLocalNotifier();
    });

// ─────────────────────────────────────────────────────────────
// Computed Tax Shield State
// ─────────────────────────────────────────────────────────────

class TaxShieldState {
  final double annualSalary;
  final double basicSalary;
  final String sector;
  final String taxRegime;

  final double otherSection80CInvestments;
  final bool hasEnteredOtherInvestments;

  final double annualEmployeeContribution;
  final double maxSection80CCD1;
  final double utilized80CCD1;
  final double available80CCD1;
  final double effective80CCD1Benefit;

  final double max80CCD1B;
  final double utilized80CCD1B;
  final double potential80CCD1B;

  final double annualEmployerContribution;
  final double max80CCD2;
  final double utilized80CCD2;
  final double available80CCD2;

  final double marginalRate;
  final double taxLeakage;
  final double currentTaxSaving;

  final double oldRegimeTax;
  final double newRegimeTax;
  final String recommendedRegime;
  final double regimeSaving;

  const TaxShieldState({
    required this.annualSalary,
    required this.basicSalary,
    required this.sector,
    required this.taxRegime,
    required this.otherSection80CInvestments,
    required this.hasEnteredOtherInvestments,
    required this.annualEmployeeContribution,
    required this.maxSection80CCD1,
    required this.utilized80CCD1,
    required this.available80CCD1,
    required this.effective80CCD1Benefit,
    required this.max80CCD1B,
    required this.utilized80CCD1B,
    required this.potential80CCD1B,
    required this.annualEmployerContribution,
    required this.max80CCD2,
    required this.utilized80CCD2,
    required this.available80CCD2,
    required this.marginalRate,
    required this.taxLeakage,
    required this.currentTaxSaving,
    required this.oldRegimeTax,
    required this.newRegimeTax,
    required this.recommendedRegime,
    required this.regimeSaving,
  });
}

// ─────────────────────────────────────────────────────────────
// Tax Helpers & Logic Engine
// ─────────────────────────────────────────────────────────────

double _applySlabs(double income, List<Map<String, double>> slabs) {
  double tax = 0;
  for (final slab in slabs) {
    if (income > slab['min']!) {
      final taxableAtSlab = min(income, slab['max']!) - slab['min']!;
      tax += taxableAtSlab * slab['rate']!;
    }
  }
  return tax;
}

double _calculateTax(
  double income,
  String regime,
  double deduction80CCD1,
  double deduction80CCD1B,
  double deduction80CCD2,
  double other80C,
) {
  final standardDeduction = 75000.0; // Budget 2024
  double tax = 0;

  if (regime == 'old') {
    final total80C = min(other80C + deduction80CCD1, 150000.0);
    final taxableIncome = max(
      0.0,
      income -
          standardDeduction -
          total80C -
          deduction80CCD1B -
          deduction80CCD2,
    );
    tax = _applySlabs(taxableIncome, AppConstants.oldRegimeSlabs);
  } else {
    // New regime only supports 80CCD(2)
    final taxableIncome = max(
      0.0,
      income - standardDeduction - deduction80CCD2,
    );
    if (taxableIncome <= 700000) {
      tax = 0; // Rebate 87A effectively makes it zero
    } else {
      tax = _applySlabs(taxableIncome, AppConstants.newRegimeSlabs);
    }
  }

  // Add 4% Health & Education Cess
  return tax + (tax * 0.04);
}

double _getMarginalRate(double income, String regime) {
  final standardDeduction = 75000.0;
  final taxableIncome = max(0.0, income - standardDeduction);

  // Rebate check
  if (regime == 'new' && taxableIncome <= 700000) return 0.0;
  if (regime == 'old' && taxableIncome <= 500000) return 0.0;

  final slabs = regime == 'old'
      ? AppConstants.oldRegimeSlabs
      : AppConstants.newRegimeSlabs;
  double rate = 0;
  for (final slab in slabs) {
    if (taxableIncome > slab['min']!) {
      rate = slab['rate']!;
    }
  }
  return rate + (rate * 0.04);
}

// ─────────────────────────────────────────────────────────────
// Computed Engine Provider
// ─────────────────────────────────────────────────────────────

final taxShieldProvider = Provider<TaxShieldState>((ref) {
  final userProfile = ref.watch(authProvider).value;
  final onboarding = ref.watch(onboardingProvider);
  final local = ref.watch(taxShieldLocalProvider);

  // Parse root configs
  final monthlySalary =
      userProfile?.monthlySalary ?? onboarding.monthlySalary ?? 0.0;
  final annualSalary = monthlySalary * 12;
  final sector = onboarding.sector ?? userProfile?.sector ?? 'private';
  final taxRegime = userProfile?.taxRegime ?? '';

  final other80C = local.otherSection80CInvestments;

  // Basic salary logic
  double basicPercent = 0.40;
  if (sector == 'central_govt' ||
      sector == 'state_govt' ||
      sector == 'government') {
    basicPercent = 0.60;
  }
  final basicSalary = sector == 'self_employed'
      ? annualSalary
      : annualSalary * basicPercent;

  // 1. 80CCD(1) - Employee Contribution (Limit 1.5L alongside 80C)
  final annualEmployeeContribution =
      (onboarding.monthlyEmployeeContribution ?? 0.0) * 12;
  double maxSection80CCD1;
  if (sector == 'self_employed') {
    maxSection80CCD1 = min(annualSalary * 0.20, 150000.0);
  } else {
    maxSection80CCD1 = min(basicSalary * 0.10, 150000.0);
  }
  final utilized80CCD1 = min(annualEmployeeContribution, maxSection80CCD1);
  final available80CCD1 = max(0.0, maxSection80CCD1 - utilized80CCD1);

  final total80CCE = min(other80C + utilized80CCD1, 150000.0);
  final effective80CCD1Benefit = max(0.0, total80CCE - other80C);

  // 2. 80CCD(1B) - Extra Tier 1 (Limit flat 50K)
  final max80CCD1B = 50000.0;
  final excessEmployeeContribution = max(
    0.0,
    annualEmployeeContribution - utilized80CCD1,
  );
  final utilized80CCD1B = min(excessEmployeeContribution, max80CCD1B);
  final potential80CCD1B = max(0.0, max80CCD1B - utilized80CCD1B);

  // 3. 80CCD(2) - Employer Contribution
  final annualEmployerContribution =
      (onboarding.monthlyEmployerContribution ?? 0.0) * 12;

  double maxPercent80CCD2 = 0.10; // Old regime private base
  if (sector == 'central_govt' ||
      sector == 'state_govt' ||
      sector == 'government') {
    maxPercent80CCD2 = 0.14;
  } else if (taxRegime == 'new') {
    maxPercent80CCD2 = 0.14; // Budget 2024 update
  }

  // For self-employed, employer contribution 80CCD(2) doesn't exist
  final max80CCD2 = sector == 'self_employed'
      ? 0.0
      : basicSalary * maxPercent80CCD2;
  final utilized80CCD2 = min(annualEmployerContribution, max80CCD2);
  final available80CCD2 = max(0.0, max80CCD2 - utilized80CCD2);

  // 4. Tax Rate Leakages
  // Use Old Regime rate if missing as it applies heavier marginals
  final evalRegime = taxRegime.isNotEmpty ? taxRegime : 'old';
  final marginalRate = _getMarginalRate(annualSalary, evalRegime);

  // Note: Only under old regime do we count 80CCD(1) and (1B)
  double activeCurrentTaxSaving = utilized80CCD2 * marginalRate;
  double activeMissedDeductions = available80CCD2;

  if (evalRegime == 'old') {
    activeCurrentTaxSaving +=
        (effective80CCD1Benefit + utilized80CCD1B) * marginalRate;
    activeMissedDeductions += (available80CCD1 + potential80CCD1B);
  }

  final taxLeakage = activeMissedDeductions * marginalRate;

  // 5. Total Computation Regimes
  final oldRegimeTax = _calculateTax(
    annualSalary,
    'old',
    effective80CCD1Benefit,
    utilized80CCD1B,
    utilized80CCD2,
    other80C,
  );

  final newRegimeTax = _calculateTax(
    annualSalary,
    'new',
    0, // not applicable in new regime
    0, // not applicable in new regime
    utilized80CCD2,
    0, // other 80C not applicable in new
  );

  final recommendedRegime = oldRegimeTax < newRegimeTax ? 'old' : 'new';
  final regimeSaving = (oldRegimeTax - newRegimeTax).abs();

  return TaxShieldState(
    annualSalary: annualSalary,
    basicSalary: basicSalary,
    sector: sector,
    taxRegime: taxRegime,
    otherSection80CInvestments: other80C,
    hasEnteredOtherInvestments: local.hasEnteredOtherInvestments,
    annualEmployeeContribution: annualEmployeeContribution,
    maxSection80CCD1: maxSection80CCD1,
    utilized80CCD1: utilized80CCD1,
    available80CCD1: available80CCD1,
    effective80CCD1Benefit: effective80CCD1Benefit,
    max80CCD1B: max80CCD1B,
    utilized80CCD1B: utilized80CCD1B,
    potential80CCD1B: potential80CCD1B,
    annualEmployerContribution: annualEmployerContribution,
    max80CCD2: max80CCD2,
    utilized80CCD2: utilized80CCD2,
    available80CCD2: available80CCD2,
    marginalRate: marginalRate,
    taxLeakage: taxLeakage,
    currentTaxSaving: activeCurrentTaxSaving,
    oldRegimeTax: oldRegimeTax,
    newRegimeTax: newRegimeTax,
    recommendedRegime: recommendedRegime,
    regimeSaving: regimeSaving,
  );
});
