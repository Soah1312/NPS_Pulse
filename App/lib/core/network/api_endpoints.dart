class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';

  // User profile
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';

  // NPS data
  static const String npsData = '/nps/data';
  static const String npsContributions = '/nps/contributions';
  static const String npsFundPerformance = '/nps/fund-performance';

  // Dream planner
  static const String lifestyleGoals = '/dream-planner/goals';
  static const String retirementProjection = '/dream-planner/projection';

  // Tax
  static const String taxCalculation = '/tax/calculate';
  static const String taxOptimization = '/tax/optimize';

  // Readiness
  static const String readinessScore = '/readiness/score';
  static const String readinessBreakdown = '/readiness/breakdown';

  // Monte Carlo
  static const String monteCarloSimulation = '/monte-carlo/simulate';

  // AI Assistant
  static const String aiChat = '/ai/chat';
  static const String aiSuggestions = '/ai/suggestions';
}
