import 'package:freezed_annotation/freezed_annotation.dart';

part 'lifestyle_goal.freezed.dart';
part 'lifestyle_goal.g.dart';

@freezed
class LifestyleGoal with _$LifestyleGoal {
  const factory LifestyleGoal({
    required String id,
    required String
    category, // 'travel' | 'home' | 'healthcare' | 'education' | 'lifestyle' | 'international'
    required String emoji,
    required String label,
    required double monthlyAmountToday,
    required double inflationRate,
    @Default(false) bool isSelected,
  }) = _LifestyleGoal;

  factory LifestyleGoal.fromJson(Map<String, dynamic> json) =>
      _$LifestyleGoalFromJson(json);
}
