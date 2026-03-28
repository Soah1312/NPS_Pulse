class AppConstants {
  AppConstants._();

  // Inflation rates by category
  static const double inflationHealthcare = 0.08;
  static const double inflationTravel = 0.06;
  static const double inflationGeneral = 0.05;
  static const double inflationEducation = 0.07;
  static const double inflationHousing = 0.06;

  // NPS rules
  static const double maxSection80CCD1Percent = 0.10; // 10% of salary
  static const double maxSection80CCD1B = 50000.0; // ₹50,000 flat
  static const double npsWithdrawalAnnuityPercent =
      0.40; // 40% must buy annuity
  static const double npsTaxFreeWithdrawalPercent =
      0.60; // 60% tax-free lump sum

  // Tax slabs (FY 2024-25 New Regime)
  static const List<Map<String, double>> newRegimeSlabs = [
    {'min': 0, 'max': 300000, 'rate': 0.0},
    {'min': 300000, 'max': 700000, 'rate': 0.05},
    {'min': 700000, 'max': 1000000, 'rate': 0.10},
    {'min': 1000000, 'max': 1200000, 'rate': 0.15},
    {'min': 1200000, 'max': 1500000, 'rate': 0.20},
    {'min': 1500000, 'max': double.infinity, 'rate': 0.30},
  ];

  // Old regime slabs
  static const List<Map<String, double>> oldRegimeSlabs = [
    {'min': 0, 'max': 250000, 'rate': 0.0},
    {'min': 250000, 'max': 500000, 'rate': 0.05},
    {'min': 500000, 'max': 1000000, 'rate': 0.20},
    {'min': 1000000, 'max': double.infinity, 'rate': 0.30},
  ];

  // Lifestyle defaults (monthly cost today in ₹)
  static const Map<String, double> lifestyleDefaultCosts = {
    'travel': 15000,
    'home': 25000,
    'healthcare': 10000,
    'education': 8000,
    'lifestyle': 20000,
    'international': 30000,
  };
}
