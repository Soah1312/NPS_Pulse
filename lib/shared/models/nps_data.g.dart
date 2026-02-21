// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nps_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NPSDataImpl _$$NPSDataImplFromJson(Map<String, dynamic> json) =>
    _$NPSDataImpl(
      userId: json['userId'] as String,
      currentCorpus: (json['currentCorpus'] as num).toDouble(),
      monthlyEmployeeContribution: (json['monthlyEmployeeContribution'] as num)
          .toDouble(),
      monthlyEmployerContribution: (json['monthlyEmployerContribution'] as num?)
          ?.toDouble(),
      fundChoice: json['fundChoice'] as String,
      equityAllocation: (json['equityAllocation'] as num?)?.toDouble(),
      stepUpEnabled: json['stepUpEnabled'] as bool? ?? false,
      stepUpPercent: (json['stepUpPercent'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$NPSDataImplToJson(_$NPSDataImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'currentCorpus': instance.currentCorpus,
      'monthlyEmployeeContribution': instance.monthlyEmployeeContribution,
      'monthlyEmployerContribution': instance.monthlyEmployerContribution,
      'fundChoice': instance.fundChoice,
      'equityAllocation': instance.equityAllocation,
      'stepUpEnabled': instance.stepUpEnabled,
      'stepUpPercent': instance.stepUpPercent,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
