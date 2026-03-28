import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String name,
    required int age,
    required String gender, // 'male' | 'female'
    required String
    sector, // 'central_govt' | 'state_govt' | 'private' | 'self_employed'
    @JsonKey(name: 'employer_name') String? employerName,
    @JsonKey(name: 'monthly_salary') required double monthlySalary,
    @JsonKey(name: 'target_retirement_age') required int targetRetirementAge,
    @JsonKey(name: 'tax_regime') required String taxRegime, // 'old' | 'new'
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
