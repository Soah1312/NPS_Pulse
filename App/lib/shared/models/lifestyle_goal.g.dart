// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lifestyle_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LifestyleGoalImpl _$$LifestyleGoalImplFromJson(Map<String, dynamic> json) =>
    _$LifestyleGoalImpl(
      id: json['id'] as String,
      category: json['category'] as String,
      emoji: json['emoji'] as String,
      label: json['label'] as String,
      monthlyAmountToday: (json['monthlyAmountToday'] as num).toDouble(),
      inflationRate: (json['inflationRate'] as num).toDouble(),
      isSelected: json['isSelected'] as bool? ?? false,
    );

Map<String, dynamic> _$$LifestyleGoalImplToJson(_$LifestyleGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'emoji': instance.emoji,
      'label': instance.label,
      'monthlyAmountToday': instance.monthlyAmountToday,
      'inflationRate': instance.inflationRate,
      'isSelected': instance.isSelected,
    };
