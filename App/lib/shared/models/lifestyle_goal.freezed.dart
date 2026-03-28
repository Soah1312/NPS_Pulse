// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lifestyle_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LifestyleGoal _$LifestyleGoalFromJson(Map<String, dynamic> json) {
  return _LifestyleGoal.fromJson(json);
}

/// @nodoc
mixin _$LifestyleGoal {
  String get id => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // 'travel' | 'home' | 'healthcare' | 'education' | 'lifestyle' | 'international'
  String get emoji => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  double get monthlyAmountToday => throw _privateConstructorUsedError;
  double get inflationRate => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;

  /// Serializes this LifestyleGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LifestyleGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LifestyleGoalCopyWith<LifestyleGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LifestyleGoalCopyWith<$Res> {
  factory $LifestyleGoalCopyWith(
    LifestyleGoal value,
    $Res Function(LifestyleGoal) then,
  ) = _$LifestyleGoalCopyWithImpl<$Res, LifestyleGoal>;
  @useResult
  $Res call({
    String id,
    String category,
    String emoji,
    String label,
    double monthlyAmountToday,
    double inflationRate,
    bool isSelected,
  });
}

/// @nodoc
class _$LifestyleGoalCopyWithImpl<$Res, $Val extends LifestyleGoal>
    implements $LifestyleGoalCopyWith<$Res> {
  _$LifestyleGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LifestyleGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? emoji = null,
    Object? label = null,
    Object? monthlyAmountToday = null,
    Object? inflationRate = null,
    Object? isSelected = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            monthlyAmountToday: null == monthlyAmountToday
                ? _value.monthlyAmountToday
                : monthlyAmountToday // ignore: cast_nullable_to_non_nullable
                      as double,
            inflationRate: null == inflationRate
                ? _value.inflationRate
                : inflationRate // ignore: cast_nullable_to_non_nullable
                      as double,
            isSelected: null == isSelected
                ? _value.isSelected
                : isSelected // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LifestyleGoalImplCopyWith<$Res>
    implements $LifestyleGoalCopyWith<$Res> {
  factory _$$LifestyleGoalImplCopyWith(
    _$LifestyleGoalImpl value,
    $Res Function(_$LifestyleGoalImpl) then,
  ) = __$$LifestyleGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String category,
    String emoji,
    String label,
    double monthlyAmountToday,
    double inflationRate,
    bool isSelected,
  });
}

/// @nodoc
class __$$LifestyleGoalImplCopyWithImpl<$Res>
    extends _$LifestyleGoalCopyWithImpl<$Res, _$LifestyleGoalImpl>
    implements _$$LifestyleGoalImplCopyWith<$Res> {
  __$$LifestyleGoalImplCopyWithImpl(
    _$LifestyleGoalImpl _value,
    $Res Function(_$LifestyleGoalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LifestyleGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? emoji = null,
    Object? label = null,
    Object? monthlyAmountToday = null,
    Object? inflationRate = null,
    Object? isSelected = null,
  }) {
    return _then(
      _$LifestyleGoalImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        monthlyAmountToday: null == monthlyAmountToday
            ? _value.monthlyAmountToday
            : monthlyAmountToday // ignore: cast_nullable_to_non_nullable
                  as double,
        inflationRate: null == inflationRate
            ? _value.inflationRate
            : inflationRate // ignore: cast_nullable_to_non_nullable
                  as double,
        isSelected: null == isSelected
            ? _value.isSelected
            : isSelected // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LifestyleGoalImpl implements _LifestyleGoal {
  const _$LifestyleGoalImpl({
    required this.id,
    required this.category,
    required this.emoji,
    required this.label,
    required this.monthlyAmountToday,
    required this.inflationRate,
    this.isSelected = false,
  });

  factory _$LifestyleGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$LifestyleGoalImplFromJson(json);

  @override
  final String id;
  @override
  final String category;
  // 'travel' | 'home' | 'healthcare' | 'education' | 'lifestyle' | 'international'
  @override
  final String emoji;
  @override
  final String label;
  @override
  final double monthlyAmountToday;
  @override
  final double inflationRate;
  @override
  @JsonKey()
  final bool isSelected;

  @override
  String toString() {
    return 'LifestyleGoal(id: $id, category: $category, emoji: $emoji, label: $label, monthlyAmountToday: $monthlyAmountToday, inflationRate: $inflationRate, isSelected: $isSelected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LifestyleGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.monthlyAmountToday, monthlyAmountToday) ||
                other.monthlyAmountToday == monthlyAmountToday) &&
            (identical(other.inflationRate, inflationRate) ||
                other.inflationRate == inflationRate) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    category,
    emoji,
    label,
    monthlyAmountToday,
    inflationRate,
    isSelected,
  );

  /// Create a copy of LifestyleGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LifestyleGoalImplCopyWith<_$LifestyleGoalImpl> get copyWith =>
      __$$LifestyleGoalImplCopyWithImpl<_$LifestyleGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LifestyleGoalImplToJson(this);
  }
}

abstract class _LifestyleGoal implements LifestyleGoal {
  const factory _LifestyleGoal({
    required final String id,
    required final String category,
    required final String emoji,
    required final String label,
    required final double monthlyAmountToday,
    required final double inflationRate,
    final bool isSelected,
  }) = _$LifestyleGoalImpl;

  factory _LifestyleGoal.fromJson(Map<String, dynamic> json) =
      _$LifestyleGoalImpl.fromJson;

  @override
  String get id;
  @override
  String get category; // 'travel' | 'home' | 'healthcare' | 'education' | 'lifestyle' | 'international'
  @override
  String get emoji;
  @override
  String get label;
  @override
  double get monthlyAmountToday;
  @override
  double get inflationRate;
  @override
  bool get isSelected;

  /// Create a copy of LifestyleGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LifestyleGoalImplCopyWith<_$LifestyleGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
