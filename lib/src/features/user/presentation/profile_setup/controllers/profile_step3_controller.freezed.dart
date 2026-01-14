// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_step3_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfileStep3State {
  EnergyLevel? get selectedLevel => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;

  /// Create a copy of ProfileStep3State
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileStep3StateCopyWith<ProfileStep3State> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStep3StateCopyWith<$Res> {
  factory $ProfileStep3StateCopyWith(
    ProfileStep3State value,
    $Res Function(ProfileStep3State) then,
  ) = _$ProfileStep3StateCopyWithImpl<$Res, ProfileStep3State>;
  @useResult
  $Res call({
    EnergyLevel? selectedLevel,
    bool isLoading,
    String? errorMessage,
    bool isSuccess,
  });
}

/// @nodoc
class _$ProfileStep3StateCopyWithImpl<$Res, $Val extends ProfileStep3State>
    implements $ProfileStep3StateCopyWith<$Res> {
  _$ProfileStep3StateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileStep3State
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedLevel = freezed,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? isSuccess = null,
  }) {
    return _then(
      _value.copyWith(
            selectedLevel: freezed == selectedLevel
                ? _value.selectedLevel
                : selectedLevel // ignore: cast_nullable_to_non_nullable
                      as EnergyLevel?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            isSuccess: null == isSuccess
                ? _value.isSuccess
                : isSuccess // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileStep3StateImplCopyWith<$Res>
    implements $ProfileStep3StateCopyWith<$Res> {
  factory _$$ProfileStep3StateImplCopyWith(
    _$ProfileStep3StateImpl value,
    $Res Function(_$ProfileStep3StateImpl) then,
  ) = __$$ProfileStep3StateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    EnergyLevel? selectedLevel,
    bool isLoading,
    String? errorMessage,
    bool isSuccess,
  });
}

/// @nodoc
class __$$ProfileStep3StateImplCopyWithImpl<$Res>
    extends _$ProfileStep3StateCopyWithImpl<$Res, _$ProfileStep3StateImpl>
    implements _$$ProfileStep3StateImplCopyWith<$Res> {
  __$$ProfileStep3StateImplCopyWithImpl(
    _$ProfileStep3StateImpl _value,
    $Res Function(_$ProfileStep3StateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileStep3State
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedLevel = freezed,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? isSuccess = null,
  }) {
    return _then(
      _$ProfileStep3StateImpl(
        selectedLevel: freezed == selectedLevel
            ? _value.selectedLevel
            : selectedLevel // ignore: cast_nullable_to_non_nullable
                  as EnergyLevel?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        isSuccess: null == isSuccess
            ? _value.isSuccess
            : isSuccess // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ProfileStep3StateImpl implements _ProfileStep3State {
  const _$ProfileStep3StateImpl({
    this.selectedLevel,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  @override
  final EnergyLevel? selectedLevel;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final bool isSuccess;

  @override
  String toString() {
    return 'ProfileStep3State(selectedLevel: $selectedLevel, isLoading: $isLoading, errorMessage: $errorMessage, isSuccess: $isSuccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStep3StateImpl &&
            (identical(other.selectedLevel, selectedLevel) ||
                other.selectedLevel == selectedLevel) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedLevel,
    isLoading,
    errorMessage,
    isSuccess,
  );

  /// Create a copy of ProfileStep3State
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileStep3StateImplCopyWith<_$ProfileStep3StateImpl> get copyWith =>
      __$$ProfileStep3StateImplCopyWithImpl<_$ProfileStep3StateImpl>(
        this,
        _$identity,
      );
}

abstract class _ProfileStep3State implements ProfileStep3State {
  const factory _ProfileStep3State({
    final EnergyLevel? selectedLevel,
    final bool isLoading,
    final String? errorMessage,
    final bool isSuccess,
  }) = _$ProfileStep3StateImpl;

  @override
  EnergyLevel? get selectedLevel;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  bool get isSuccess;

  /// Create a copy of ProfileStep3State
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileStep3StateImplCopyWith<_$ProfileStep3StateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
