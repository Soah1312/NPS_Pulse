// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nps_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NPSData _$NPSDataFromJson(Map<String, dynamic> json) {
  return _NPSData.fromJson(json);
}

/// @nodoc
mixin _$NPSData {
  String get userId => throw _privateConstructorUsedError;
  double get currentCorpus => throw _privateConstructorUsedError;
  double get monthlyEmployeeContribution => throw _privateConstructorUsedError;
  double? get monthlyEmployerContribution => throw _privateConstructorUsedError;
  String get fundChoice =>
      throw _privateConstructorUsedError; // 'active' | 'auto'
  double? get equityAllocation =>
      throw _privateConstructorUsedError; // % if active choice
  bool get stepUpEnabled => throw _privateConstructorUsedError;
  double get stepUpPercent => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this NPSData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NPSData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NPSDataCopyWith<NPSData> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NPSDataCopyWith<$Res> {
  factory $NPSDataCopyWith(NPSData value, $Res Function(NPSData) then) =
      _$NPSDataCopyWithImpl<$Res, NPSData>;
  @useResult
  $Res call({
    String userId,
    double currentCorpus,
    double monthlyEmployeeContribution,
    double? monthlyEmployerContribution,
    String fundChoice,
    double? equityAllocation,
    bool stepUpEnabled,
    double stepUpPercent,
    DateTime? lastUpdated,
  });
}

/// @nodoc
class _$NPSDataCopyWithImpl<$Res, $Val extends NPSData>
    implements $NPSDataCopyWith<$Res> {
  _$NPSDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NPSData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? currentCorpus = null,
    Object? monthlyEmployeeContribution = null,
    Object? monthlyEmployerContribution = freezed,
    Object? fundChoice = null,
    Object? equityAllocation = freezed,
    Object? stepUpEnabled = null,
    Object? stepUpPercent = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            currentCorpus: null == currentCorpus
                ? _value.currentCorpus
                : currentCorpus // ignore: cast_nullable_to_non_nullable
                      as double,
            monthlyEmployeeContribution: null == monthlyEmployeeContribution
                ? _value.monthlyEmployeeContribution
                : monthlyEmployeeContribution // ignore: cast_nullable_to_non_nullable
                      as double,
            monthlyEmployerContribution: freezed == monthlyEmployerContribution
                ? _value.monthlyEmployerContribution
                : monthlyEmployerContribution // ignore: cast_nullable_to_non_nullable
                      as double?,
            fundChoice: null == fundChoice
                ? _value.fundChoice
                : fundChoice // ignore: cast_nullable_to_non_nullable
                      as String,
            equityAllocation: freezed == equityAllocation
                ? _value.equityAllocation
                : equityAllocation // ignore: cast_nullable_to_non_nullable
                      as double?,
            stepUpEnabled: null == stepUpEnabled
                ? _value.stepUpEnabled
                : stepUpEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            stepUpPercent: null == stepUpPercent
                ? _value.stepUpPercent
                : stepUpPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            lastUpdated: freezed == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NPSDataImplCopyWith<$Res> implements $NPSDataCopyWith<$Res> {
  factory _$$NPSDataImplCopyWith(
    _$NPSDataImpl value,
    $Res Function(_$NPSDataImpl) then,
  ) = __$$NPSDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    double currentCorpus,
    double monthlyEmployeeContribution,
    double? monthlyEmployerContribution,
    String fundChoice,
    double? equityAllocation,
    bool stepUpEnabled,
    double stepUpPercent,
    DateTime? lastUpdated,
  });
}

/// @nodoc
class __$$NPSDataImplCopyWithImpl<$Res>
    extends _$NPSDataCopyWithImpl<$Res, _$NPSDataImpl>
    implements _$$NPSDataImplCopyWith<$Res> {
  __$$NPSDataImplCopyWithImpl(
    _$NPSDataImpl _value,
    $Res Function(_$NPSDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NPSData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? currentCorpus = null,
    Object? monthlyEmployeeContribution = null,
    Object? monthlyEmployerContribution = freezed,
    Object? fundChoice = null,
    Object? equityAllocation = freezed,
    Object? stepUpEnabled = null,
    Object? stepUpPercent = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _$NPSDataImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        currentCorpus: null == currentCorpus
            ? _value.currentCorpus
            : currentCorpus // ignore: cast_nullable_to_non_nullable
                  as double,
        monthlyEmployeeContribution: null == monthlyEmployeeContribution
            ? _value.monthlyEmployeeContribution
            : monthlyEmployeeContribution // ignore: cast_nullable_to_non_nullable
                  as double,
        monthlyEmployerContribution: freezed == monthlyEmployerContribution
            ? _value.monthlyEmployerContribution
            : monthlyEmployerContribution // ignore: cast_nullable_to_non_nullable
                  as double?,
        fundChoice: null == fundChoice
            ? _value.fundChoice
            : fundChoice // ignore: cast_nullable_to_non_nullable
                  as String,
        equityAllocation: freezed == equityAllocation
            ? _value.equityAllocation
            : equityAllocation // ignore: cast_nullable_to_non_nullable
                  as double?,
        stepUpEnabled: null == stepUpEnabled
            ? _value.stepUpEnabled
            : stepUpEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        stepUpPercent: null == stepUpPercent
            ? _value.stepUpPercent
            : stepUpPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        lastUpdated: freezed == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NPSDataImpl implements _NPSData {
  const _$NPSDataImpl({
    required this.userId,
    required this.currentCorpus,
    required this.monthlyEmployeeContribution,
    this.monthlyEmployerContribution,
    required this.fundChoice,
    this.equityAllocation,
    this.stepUpEnabled = false,
    this.stepUpPercent = 0.0,
    this.lastUpdated,
  });

  factory _$NPSDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$NPSDataImplFromJson(json);

  @override
  final String userId;
  @override
  final double currentCorpus;
  @override
  final double monthlyEmployeeContribution;
  @override
  final double? monthlyEmployerContribution;
  @override
  final String fundChoice;
  // 'active' | 'auto'
  @override
  final double? equityAllocation;
  // % if active choice
  @override
  @JsonKey()
  final bool stepUpEnabled;
  @override
  @JsonKey()
  final double stepUpPercent;
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'NPSData(userId: $userId, currentCorpus: $currentCorpus, monthlyEmployeeContribution: $monthlyEmployeeContribution, monthlyEmployerContribution: $monthlyEmployerContribution, fundChoice: $fundChoice, equityAllocation: $equityAllocation, stepUpEnabled: $stepUpEnabled, stepUpPercent: $stepUpPercent, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NPSDataImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.currentCorpus, currentCorpus) ||
                other.currentCorpus == currentCorpus) &&
            (identical(
                  other.monthlyEmployeeContribution,
                  monthlyEmployeeContribution,
                ) ||
                other.monthlyEmployeeContribution ==
                    monthlyEmployeeContribution) &&
            (identical(
                  other.monthlyEmployerContribution,
                  monthlyEmployerContribution,
                ) ||
                other.monthlyEmployerContribution ==
                    monthlyEmployerContribution) &&
            (identical(other.fundChoice, fundChoice) ||
                other.fundChoice == fundChoice) &&
            (identical(other.equityAllocation, equityAllocation) ||
                other.equityAllocation == equityAllocation) &&
            (identical(other.stepUpEnabled, stepUpEnabled) ||
                other.stepUpEnabled == stepUpEnabled) &&
            (identical(other.stepUpPercent, stepUpPercent) ||
                other.stepUpPercent == stepUpPercent) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    currentCorpus,
    monthlyEmployeeContribution,
    monthlyEmployerContribution,
    fundChoice,
    equityAllocation,
    stepUpEnabled,
    stepUpPercent,
    lastUpdated,
  );

  /// Create a copy of NPSData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NPSDataImplCopyWith<_$NPSDataImpl> get copyWith =>
      __$$NPSDataImplCopyWithImpl<_$NPSDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NPSDataImplToJson(this);
  }
}

abstract class _NPSData implements NPSData {
  const factory _NPSData({
    required final String userId,
    required final double currentCorpus,
    required final double monthlyEmployeeContribution,
    final double? monthlyEmployerContribution,
    required final String fundChoice,
    final double? equityAllocation,
    final bool stepUpEnabled,
    final double stepUpPercent,
    final DateTime? lastUpdated,
  }) = _$NPSDataImpl;

  factory _NPSData.fromJson(Map<String, dynamic> json) = _$NPSDataImpl.fromJson;

  @override
  String get userId;
  @override
  double get currentCorpus;
  @override
  double get monthlyEmployeeContribution;
  @override
  double? get monthlyEmployerContribution;
  @override
  String get fundChoice; // 'active' | 'auto'
  @override
  double? get equityAllocation; // % if active choice
  @override
  bool get stepUpEnabled;
  @override
  double get stepUpPercent;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of NPSData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NPSDataImplCopyWith<_$NPSDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
