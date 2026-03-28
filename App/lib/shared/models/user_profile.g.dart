// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      sector: json['sector'] as String,
      employerName: json['employer_name'] as String?,
      monthlySalary: (json['monthly_salary'] as num).toDouble(),
      targetRetirementAge: (json['target_retirement_age'] as num).toInt(),
      taxRegime: json['tax_regime'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'sector': instance.sector,
      'employer_name': instance.employerName,
      'monthly_salary': instance.monthlySalary,
      'target_retirement_age': instance.targetRetirementAge,
      'tax_regime': instance.taxRegime,
      'created_at': instance.createdAt?.toIso8601String(),
    };
