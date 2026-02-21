import 'package:freezed_annotation/freezed_annotation.dart';

part 'nps_data.freezed.dart';
part 'nps_data.g.dart';

@freezed
class NPSData with _$NPSData {
  const factory NPSData({
    required String userId,
    required double currentCorpus,
    required double monthlyEmployeeContribution,
    double? monthlyEmployerContribution,
    required String fundChoice, // 'active' | 'auto'
    double? equityAllocation, // % if active choice
    @Default(false) bool stepUpEnabled,
    @Default(0.0) double stepUpPercent,
    DateTime? lastUpdated,
  }) = _NPSData;

  factory NPSData.fromJson(Map<String, dynamic> json) =>
      _$NPSDataFromJson(json);
}
