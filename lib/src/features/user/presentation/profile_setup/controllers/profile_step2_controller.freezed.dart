// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_step2_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfileStep2State {
  List<String> get selectedInterests => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;

  /// Create a copy of ProfileStep2State
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileStep2StateCopyWith<ProfileStep2State> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStep2StateCopyWith<$Res> {
  factory $ProfileStep2StateCopyWith(
    ProfileStep2State value,
    $Res Function(ProfileStep2State) then,
  ) = _$ProfileStep2StateCopyWithImpl<$Res, ProfileStep2State>;
  @useResult
  $Res call({
    List<String> selectedInterests,
    bool isLoading,
    String? errorMessage,
    bool isSuccess,
  });
}

/// @nodoc
class _$ProfileStep2StateCopyWithImpl<$Res, $Val extends ProfileStep2State>
    implements $ProfileStep2StateCopyWith<$Res> {
  _$ProfileStep2StateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileStep2State
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedInterests = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? isSuccess = null,
  }) {
    return _then(
      _value.copyWith(
            selectedInterests: null == selectedInterests
                ? _value.selectedInterests
                : selectedInterests // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
abstract class _$$ProfileStep2StateImplCopyWith<$Res>
    implements $ProfileStep2StateCopyWith<$Res> {
  factory _$$ProfileStep2StateImplCopyWith(
    _$ProfileStep2StateImpl value,
    $Res Function(_$ProfileStep2StateImpl) then,
  ) = __$$ProfileStep2StateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String> selectedInterests,
    bool isLoading,
    String? errorMessage,
    bool isSuccess,
  });
}

/// @nodoc
class __$$ProfileStep2StateImplCopyWithImpl<$Res>
    extends _$ProfileStep2StateCopyWithImpl<$Res, _$ProfileStep2StateImpl>
    implements _$$ProfileStep2StateImplCopyWith<$Res> {
  __$$ProfileStep2StateImplCopyWithImpl(
    _$ProfileStep2StateImpl _value,
    $Res Function(_$ProfileStep2StateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileStep2State
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedInterests = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? isSuccess = null,
  }) {
    return _then(
      _$ProfileStep2StateImpl(
        selectedInterests: null == selectedInterests
            ? _value._selectedInterests
            : selectedInterests // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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

class _$ProfileStep2StateImpl implements _ProfileStep2State {
  const _$ProfileStep2StateImpl({
    final List<String> selectedInterests = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  }) : _selectedInterests = selectedInterests;

  final List<String> _selectedInterests;
  @override
  @JsonKey()
  List<String> get selectedInterests {
    if (_selectedInterests is EqualUnmodifiableListView)
      return _selectedInterests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedInterests);
  }

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
    return 'ProfileStep2State(selectedInterests: $selectedInterests, isLoading: $isLoading, errorMessage: $errorMessage, isSuccess: $isSuccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStep2StateImpl &&
            const DeepCollectionEquality().equals(
              other._selectedInterests,
              _selectedInterests,
            ) &&
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
    const DeepCollectionEquality().hash(_selectedInterests),
    isLoading,
    errorMessage,
    isSuccess,
  );

  /// Create a copy of ProfileStep2State
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileStep2StateImplCopyWith<_$ProfileStep2StateImpl> get copyWith =>
      __$$ProfileStep2StateImplCopyWithImpl<_$ProfileStep2StateImpl>(
        this,
        _$identity,
      );
}

abstract class _ProfileStep2State implements ProfileStep2State {
  const factory _ProfileStep2State({
    final List<String> selectedInterests,
    final bool isLoading,
    final String? errorMessage,
    final bool isSuccess,
  }) = _$ProfileStep2StateImpl;

  @override
  List<String> get selectedInterests;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  bool get isSuccess;

  /// Create a copy of ProfileStep2State
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileStep2StateImplCopyWith<_$ProfileStep2StateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
