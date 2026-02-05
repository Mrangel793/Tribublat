// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_setup_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfileSetupState {
  // Paso actual (0-2)
  int get currentStep =>
      throw _privateConstructorUsedError; // Step 1: Info Básica
  String get ciudad => throw _privateConstructorUsedError;
  String get ciudadQuery => throw _privateConstructorUsedError;
  List<String> get ciudadesSugeridas => throw _privateConstructorUsedError;
  int get edad => throw _privateConstructorUsedError;
  String get fotoBase64 =>
      throw _privateConstructorUsedError; // Step 2: Intereses
  List<String> get interesesSeleccionados => throw _privateConstructorUsedError;
  String get busquedaInteres =>
      throw _privateConstructorUsedError; // Step 3: Energía Social
  EnergyLevel get nivelEnergia => throw _privateConstructorUsedError; // Estados
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;
  bool get isBuscandoCiudades => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of ProfileSetupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileSetupStateCopyWith<ProfileSetupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileSetupStateCopyWith<$Res> {
  factory $ProfileSetupStateCopyWith(
    ProfileSetupState value,
    $Res Function(ProfileSetupState) then,
  ) = _$ProfileSetupStateCopyWithImpl<$Res, ProfileSetupState>;
  @useResult
  $Res call({
    int currentStep,
    String ciudad,
    String ciudadQuery,
    List<String> ciudadesSugeridas,
    int edad,
    String fotoBase64,
    List<String> interesesSeleccionados,
    String busquedaInteres,
    EnergyLevel nivelEnergia,
    bool isLoading,
    bool isSuccess,
    bool isBuscandoCiudades,
    String? errorMessage,
  });
}

/// @nodoc
class _$ProfileSetupStateCopyWithImpl<$Res, $Val extends ProfileSetupState>
    implements $ProfileSetupStateCopyWith<$Res> {
  _$ProfileSetupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileSetupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? ciudad = null,
    Object? ciudadQuery = null,
    Object? ciudadesSugeridas = null,
    Object? edad = null,
    Object? fotoBase64 = null,
    Object? interesesSeleccionados = null,
    Object? busquedaInteres = null,
    Object? nivelEnergia = null,
    Object? isLoading = null,
    Object? isSuccess = null,
    Object? isBuscandoCiudades = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentStep: null == currentStep
                ? _value.currentStep
                : currentStep // ignore: cast_nullable_to_non_nullable
                      as int,
            ciudad: null == ciudad
                ? _value.ciudad
                : ciudad // ignore: cast_nullable_to_non_nullable
                      as String,
            ciudadQuery: null == ciudadQuery
                ? _value.ciudadQuery
                : ciudadQuery // ignore: cast_nullable_to_non_nullable
                      as String,
            ciudadesSugeridas: null == ciudadesSugeridas
                ? _value.ciudadesSugeridas
                : ciudadesSugeridas // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            edad: null == edad
                ? _value.edad
                : edad // ignore: cast_nullable_to_non_nullable
                      as int,
            fotoBase64: null == fotoBase64
                ? _value.fotoBase64
                : fotoBase64 // ignore: cast_nullable_to_non_nullable
                      as String,
            interesesSeleccionados: null == interesesSeleccionados
                ? _value.interesesSeleccionados
                : interesesSeleccionados // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            busquedaInteres: null == busquedaInteres
                ? _value.busquedaInteres
                : busquedaInteres // ignore: cast_nullable_to_non_nullable
                      as String,
            nivelEnergia: null == nivelEnergia
                ? _value.nivelEnergia
                : nivelEnergia // ignore: cast_nullable_to_non_nullable
                      as EnergyLevel,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSuccess: null == isSuccess
                ? _value.isSuccess
                : isSuccess // ignore: cast_nullable_to_non_nullable
                      as bool,
            isBuscandoCiudades: null == isBuscandoCiudades
                ? _value.isBuscandoCiudades
                : isBuscandoCiudades // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileSetupStateImplCopyWith<$Res>
    implements $ProfileSetupStateCopyWith<$Res> {
  factory _$$ProfileSetupStateImplCopyWith(
    _$ProfileSetupStateImpl value,
    $Res Function(_$ProfileSetupStateImpl) then,
  ) = __$$ProfileSetupStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int currentStep,
    String ciudad,
    String ciudadQuery,
    List<String> ciudadesSugeridas,
    int edad,
    String fotoBase64,
    List<String> interesesSeleccionados,
    String busquedaInteres,
    EnergyLevel nivelEnergia,
    bool isLoading,
    bool isSuccess,
    bool isBuscandoCiudades,
    String? errorMessage,
  });
}

/// @nodoc
class __$$ProfileSetupStateImplCopyWithImpl<$Res>
    extends _$ProfileSetupStateCopyWithImpl<$Res, _$ProfileSetupStateImpl>
    implements _$$ProfileSetupStateImplCopyWith<$Res> {
  __$$ProfileSetupStateImplCopyWithImpl(
    _$ProfileSetupStateImpl _value,
    $Res Function(_$ProfileSetupStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileSetupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? ciudad = null,
    Object? ciudadQuery = null,
    Object? ciudadesSugeridas = null,
    Object? edad = null,
    Object? fotoBase64 = null,
    Object? interesesSeleccionados = null,
    Object? busquedaInteres = null,
    Object? nivelEnergia = null,
    Object? isLoading = null,
    Object? isSuccess = null,
    Object? isBuscandoCiudades = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$ProfileSetupStateImpl(
        currentStep: null == currentStep
            ? _value.currentStep
            : currentStep // ignore: cast_nullable_to_non_nullable
                  as int,
        ciudad: null == ciudad
            ? _value.ciudad
            : ciudad // ignore: cast_nullable_to_non_nullable
                  as String,
        ciudadQuery: null == ciudadQuery
            ? _value.ciudadQuery
            : ciudadQuery // ignore: cast_nullable_to_non_nullable
                  as String,
        ciudadesSugeridas: null == ciudadesSugeridas
            ? _value._ciudadesSugeridas
            : ciudadesSugeridas // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        edad: null == edad
            ? _value.edad
            : edad // ignore: cast_nullable_to_non_nullable
                  as int,
        fotoBase64: null == fotoBase64
            ? _value.fotoBase64
            : fotoBase64 // ignore: cast_nullable_to_non_nullable
                  as String,
        interesesSeleccionados: null == interesesSeleccionados
            ? _value._interesesSeleccionados
            : interesesSeleccionados // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        busquedaInteres: null == busquedaInteres
            ? _value.busquedaInteres
            : busquedaInteres // ignore: cast_nullable_to_non_nullable
                  as String,
        nivelEnergia: null == nivelEnergia
            ? _value.nivelEnergia
            : nivelEnergia // ignore: cast_nullable_to_non_nullable
                  as EnergyLevel,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSuccess: null == isSuccess
            ? _value.isSuccess
            : isSuccess // ignore: cast_nullable_to_non_nullable
                  as bool,
        isBuscandoCiudades: null == isBuscandoCiudades
            ? _value.isBuscandoCiudades
            : isBuscandoCiudades // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ProfileSetupStateImpl extends _ProfileSetupState {
  const _$ProfileSetupStateImpl({
    this.currentStep = 0,
    this.ciudad = '',
    this.ciudadQuery = '',
    final List<String> ciudadesSugeridas = const [],
    this.edad = 18,
    this.fotoBase64 = '',
    final List<String> interesesSeleccionados = const [],
    this.busquedaInteres = '',
    this.nivelEnergia = EnergyLevel.media,
    this.isLoading = false,
    this.isSuccess = false,
    this.isBuscandoCiudades = false,
    this.errorMessage,
  }) : _ciudadesSugeridas = ciudadesSugeridas,
       _interesesSeleccionados = interesesSeleccionados,
       super._();

  // Paso actual (0-2)
  @override
  @JsonKey()
  final int currentStep;
  // Step 1: Info Básica
  @override
  @JsonKey()
  final String ciudad;
  @override
  @JsonKey()
  final String ciudadQuery;
  final List<String> _ciudadesSugeridas;
  @override
  @JsonKey()
  List<String> get ciudadesSugeridas {
    if (_ciudadesSugeridas is EqualUnmodifiableListView)
      return _ciudadesSugeridas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ciudadesSugeridas);
  }

  @override
  @JsonKey()
  final int edad;
  @override
  @JsonKey()
  final String fotoBase64;
  // Step 2: Intereses
  final List<String> _interesesSeleccionados;
  // Step 2: Intereses
  @override
  @JsonKey()
  List<String> get interesesSeleccionados {
    if (_interesesSeleccionados is EqualUnmodifiableListView)
      return _interesesSeleccionados;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interesesSeleccionados);
  }

  @override
  @JsonKey()
  final String busquedaInteres;
  // Step 3: Energía Social
  @override
  @JsonKey()
  final EnergyLevel nivelEnergia;
  // Estados
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSuccess;
  @override
  @JsonKey()
  final bool isBuscandoCiudades;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ProfileSetupState(currentStep: $currentStep, ciudad: $ciudad, ciudadQuery: $ciudadQuery, ciudadesSugeridas: $ciudadesSugeridas, edad: $edad, fotoBase64: $fotoBase64, interesesSeleccionados: $interesesSeleccionados, busquedaInteres: $busquedaInteres, nivelEnergia: $nivelEnergia, isLoading: $isLoading, isSuccess: $isSuccess, isBuscandoCiudades: $isBuscandoCiudades, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileSetupStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.ciudad, ciudad) || other.ciudad == ciudad) &&
            (identical(other.ciudadQuery, ciudadQuery) ||
                other.ciudadQuery == ciudadQuery) &&
            const DeepCollectionEquality().equals(
              other._ciudadesSugeridas,
              _ciudadesSugeridas,
            ) &&
            (identical(other.edad, edad) || other.edad == edad) &&
            (identical(other.fotoBase64, fotoBase64) ||
                other.fotoBase64 == fotoBase64) &&
            const DeepCollectionEquality().equals(
              other._interesesSeleccionados,
              _interesesSeleccionados,
            ) &&
            (identical(other.busquedaInteres, busquedaInteres) ||
                other.busquedaInteres == busquedaInteres) &&
            (identical(other.nivelEnergia, nivelEnergia) ||
                other.nivelEnergia == nivelEnergia) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess) &&
            (identical(other.isBuscandoCiudades, isBuscandoCiudades) ||
                other.isBuscandoCiudades == isBuscandoCiudades) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentStep,
    ciudad,
    ciudadQuery,
    const DeepCollectionEquality().hash(_ciudadesSugeridas),
    edad,
    fotoBase64,
    const DeepCollectionEquality().hash(_interesesSeleccionados),
    busquedaInteres,
    nivelEnergia,
    isLoading,
    isSuccess,
    isBuscandoCiudades,
    errorMessage,
  );

  /// Create a copy of ProfileSetupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileSetupStateImplCopyWith<_$ProfileSetupStateImpl> get copyWith =>
      __$$ProfileSetupStateImplCopyWithImpl<_$ProfileSetupStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ProfileSetupState extends ProfileSetupState {
  const factory _ProfileSetupState({
    final int currentStep,
    final String ciudad,
    final String ciudadQuery,
    final List<String> ciudadesSugeridas,
    final int edad,
    final String fotoBase64,
    final List<String> interesesSeleccionados,
    final String busquedaInteres,
    final EnergyLevel nivelEnergia,
    final bool isLoading,
    final bool isSuccess,
    final bool isBuscandoCiudades,
    final String? errorMessage,
  }) = _$ProfileSetupStateImpl;
  const _ProfileSetupState._() : super._();

  // Paso actual (0-2)
  @override
  int get currentStep; // Step 1: Info Básica
  @override
  String get ciudad;
  @override
  String get ciudadQuery;
  @override
  List<String> get ciudadesSugeridas;
  @override
  int get edad;
  @override
  String get fotoBase64; // Step 2: Intereses
  @override
  List<String> get interesesSeleccionados;
  @override
  String get busquedaInteres; // Step 3: Energía Social
  @override
  EnergyLevel get nivelEnergia; // Estados
  @override
  bool get isLoading;
  @override
  bool get isSuccess;
  @override
  bool get isBuscandoCiudades;
  @override
  String? get errorMessage;

  /// Create a copy of ProfileSetupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileSetupStateImplCopyWith<_$ProfileSetupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
