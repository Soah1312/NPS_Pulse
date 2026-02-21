import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/lifestyle_goal.dart';

class UserDataService {
  static const String _stepUpEnabledKey = 'step_up_enabled';
  static const String _stepUpPercentKey = 'step_up_percent';
  static const String _equityAllocationKey = 'equity_allocation';
  static const String _lifestyleGoalsKey = 'lifestyle_goals';
  static const String _simulatedContributionKey = 'simulated_contribution';

  final SharedPreferences _prefs;

  UserDataService(this._prefs);

  static Future<UserDataService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return UserDataService(prefs);
  }

  // NPS Simulation Settings
  bool get stepUpEnabled => _prefs.getBool(_stepUpEnabledKey) ?? false;
  Future<void> saveStepUpEnabled(bool enabled) =>
      _prefs.setBool(_stepUpEnabledKey, enabled);

  double get stepUpPercent => _prefs.getDouble(_stepUpPercentKey) ?? 0.0;
  Future<void> saveStepUpPercent(double percent) =>
      _prefs.setDouble(_stepUpPercentKey, percent);

  double get equityAllocation => _prefs.getDouble(_equityAllocationKey) ?? 0.50;
  Future<void> saveEquityAllocation(double allocation) =>
      _prefs.setDouble(_equityAllocationKey, allocation);

  double? get simulatedContribution =>
      _prefs.getDouble(_simulatedContributionKey);
  Future<void> saveSimulatedContribution(double contribution) =>
      _prefs.setDouble(_simulatedContributionKey, contribution);

  // Lifestyle Goals Customizations
  List<LifestyleGoal>? getLifestyleGoals() {
    final String? goalsString = _prefs.getString(_lifestyleGoalsKey);
    if (goalsString == null) return null;

    try {
      final List<dynamic> decoded = jsonDecode(goalsString);
      return decoded
          .map((item) => LifestyleGoal.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> saveLifestyleGoals(List<LifestyleGoal> goals) async {
    final List<Map<String, dynamic>> goalsList = goals
        .map((g) => g.toJson())
        .toList();
    await _prefs.setString(_lifestyleGoalsKey, jsonEncode(goalsList));
  }

  Future<void> clearSimulationData() async {
    await _prefs.remove(_stepUpEnabledKey);
    await _prefs.remove(_stepUpPercentKey);
    await _prefs.remove(_equityAllocationKey);
    await _prefs.remove(_simulatedContributionKey);
    await _prefs.remove(_lifestyleGoalsKey);
  }
}
