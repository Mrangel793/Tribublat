// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_plan_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CreatePlanState {
  // Paso actual (0-3)
  int get currentStep => throw _privateConstructorUsedError; // Step 1: Básico
  String get titulo => throw _privateConstructorUsedError;
  String get descripcion => throw _privateConstructorUsedError;
  PlanCategory? get categoria => throw _privateConstructorUsedError;
  EnergyLevel get nivelEnergia => throw _privateConstructorUsedError;
  int get capacidadMaxima => throw _privateConstructorUsedError;
  bool get tieneCosto => throw _privateConstructorUsedError;
  double get precio => throw _privateConstructorUsedError; // Step 2: Detalles
  DateTime? get fecha => throw _privateConstructorUsedError;
  DateTime? get horaInicio => throw _privateConstructorUsedError;
  DateTime? get horaFin => throw _privateConstructorUsedError;
  int get duracionMinutos =>
      throw _privateConstructorUsedError; // Step 3: Ubicación
  String get ciudad => throw _privateConstructorUsedError;
  String get ubicacionNombre => throw _privateConstructorUsedError;
  double get latitud => throw _privateConstructorUsedError;
  double get longitud => throw _privateConstructorUsedError; // Step 4: Publicar
  bool get esPublico => throw _privateConstructorUsedError;
  bool get requiereAprobacion => throw _privateConstructorUsedError;
  String get imagenBase64 =>
      throw _privateConstructorUsedError; // === OPCIONES DE DESTACADO (solo negocios) ===
  bool get esDestacado => throw _privateConstructorUsedError;
  SponsorTier get tipoDestacado => throw _privateConstructorUsedError;
  int get diasDestacado => throw _privateConstructorUsedError;
  bool get puedeDestacar => throw _privateConstructorUsedError; // Estados
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get createdPlanId =>
      throw _privateConstructorUsedError; // Datos del usuario
  UserModel? get currentUser => throw _privateConstructorUsedError;

  /// Create a copy of CreatePlanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreatePlanStateCopyWith<CreatePlanState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatePlanStateCopyWith<$Res> {
  factory $CreatePlanStateCopyWith(
    CreatePlanState value,
    $Res Function(CreatePlanState) then,
  ) = _$CreatePlanStateCopyWithImpl<$Res, CreatePlanState>;
  @useResult
  $Res call({
    int currentStep,
    String titulo,
    String descripcion,
    PlanCategory? categoria,
    EnergyLevel nivelEnergia,
    int capacidadMaxima,
    bool tieneCosto,
    double precio,
    DateTime? fecha,
    DateTime? horaInicio,
    DateTime? horaFin,
    int duracionMinutos,
    String ciudad,
    String ubicacionNombre,
    double latitud,
    double longitud,
    bool esPublico,
    bool requiereAprobacion,
    String imagenBase64,
    bool esDestacado,
    SponsorTier tipoDestacado,
    int diasDestacado,
    bool puedeDestacar,
    bool isLoading,
    bool isSuccess,
    String? errorMessage,
    String? createdPlanId,
    UserModel? currentUser,
  });

  $UserModelCopyWith<$Res>? get currentUser;
}

/// @nodoc
class _$CreatePlanStateCopyWithImpl<$Res, $Val extends CreatePlanState>
    implements $CreatePlanStateCopyWith<$Res> {
  _$CreatePlanStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreatePlanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? titulo = null,
    Object? descripcion = null,
    Object? categoria = freezed,
    Object? nivelEnergia = null,
    Object? capacidadMaxima = null,
    Object? tieneCosto = null,
    Object? precio = null,
    Object? fecha = freezed,
    Object? horaInicio = freezed,
    Object? horaFin = freezed,
    Object? duracionMinutos = null,
    Object? ciudad = null,
    Object? ubicacionNombre = null,
    Object? latitud = null,
    Object? longitud = null,
    Object? esPublico = null,
    Object? requiereAprobacion = null,
    Object? imagenBase64 = null,
    Object? esDestacado = null,
    Object? tipoDestacado = null,
    Object? diasDestacado = null,
    Object? puedeDestacar = null,
    Object? isLoading = null,
    Object? isSuccess = null,
    Object? errorMessage = freezed,
    Object? createdPlanId = freezed,
    Object? currentUser = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentStep: null == currentStep
                ? _value.currentStep
                : currentStep // ignore: cast_nullable_to_non_nullable
                      as int,
            titulo: null == titulo
                ? _value.titulo
                : titulo // ignore: cast_nullable_to_non_nullable
                      as String,
            descripcion: null == descripcion
                ? _value.descripcion
                : descripcion // ignore: cast_nullable_to_non_nullable
                      as String,
            categoria: freezed == categoria
                ? _value.categoria
                : categoria // ignore: cast_nullable_to_non_nullable
                      as PlanCategory?,
            nivelEnergia: null == nivelEnergia
                ? _value.nivelEnergia
                : nivelEnergia // ignore: cast_nullable_to_non_nullable
                      as EnergyLevel,
            capacidadMaxima: null == capacidadMaxima
                ? _value.capacidadMaxima
                : capacidadMaxima // ignore: cast_nullable_to_non_nullable
                      as int,
            tieneCosto: null == tieneCosto
                ? _value.tieneCosto
                : tieneCosto // ignore: cast_nullable_to_non_nullable
                      as bool,
            precio: null == precio
                ? _value.precio
                : precio // ignore: cast_nullable_to_non_nullable
                      as double,
            fecha: freezed == fecha
                ? _value.fecha
                : fecha // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            horaInicio: freezed == horaInicio
                ? _value.horaInicio
                : horaInicio // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            horaFin: freezed == horaFin
                ? _value.horaFin
                : horaFin // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            duracionMinutos: null == duracionMinutos
                ? _value.duracionMinutos
                : duracionMinutos // ignore: cast_nullable_to_non_nullable
                      as int,
            ciudad: null == ciudad
                ? _value.ciudad
                : ciudad // ignore: cast_nullable_to_non_nullable
                      as String,
            ubicacionNombre: null == ubicacionNombre
                ? _value.ubicacionNombre
                : ubicacionNombre // ignore: cast_nullable_to_non_nullable
                      as String,
            latitud: null == latitud
                ? _value.latitud
                : latitud // ignore: cast_nullable_to_non_nullable
                      as double,
            longitud: null == longitud
                ? _value.longitud
                : longitud // ignore: cast_nullable_to_non_nullable
                      as double,
            esPublico: null == esPublico
                ? _value.esPublico
                : esPublico // ignore: cast_nullable_to_non_nullable
                      as bool,
            requiereAprobacion: null == requiereAprobacion
                ? _value.requiereAprobacion
                : requiereAprobacion // ignore: cast_nullable_to_non_nullable
                      as bool,
            imagenBase64: null == imagenBase64
                ? _value.imagenBase64
                : imagenBase64 // ignore: cast_nullable_to_non_nullable
                      as String,
            esDestacado: null == esDestacado
                ? _value.esDestacado
                : esDestacado // ignore: cast_nullable_to_non_nullable
                      as bool,
            tipoDestacado: null == tipoDestacado
                ? _value.tipoDestacado
                : tipoDestacado // ignore: cast_nullable_to_non_nullable
                      as SponsorTier,
            diasDestacado: null == diasDestacado
                ? _value.diasDestacado
                : diasDestacado // ignore: cast_nullable_to_non_nullable
                      as int,
            puedeDestacar: null == puedeDestacar
                ? _value.puedeDestacar
                : puedeDestacar // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSuccess: null == isSuccess
                ? _value.isSuccess
                : isSuccess // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdPlanId: freezed == createdPlanId
                ? _value.createdPlanId
                : createdPlanId // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentUser: freezed == currentUser
                ? _value.currentUser
                : currentUser // ignore: cast_nullable_to_non_nullable
                      as UserModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of CreatePlanState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get currentUser {
    if (_value.currentUser == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.currentUser!, (value) {
      return _then(_value.copyWith(currentUser: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreatePlanStateImplCopyWith<$Res>
    implements $CreatePlanStateCopyWith<$Res> {
  factory _$$CreatePlanStateImplCopyWith(
    _$CreatePlanStateImpl value,
    $Res Function(_$CreatePlanStateImpl) then,
  ) = __$$CreatePlanStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int currentStep,
    String titulo,
    String descripcion,
    PlanCategory? categoria,
    EnergyLevel nivelEnergia,
    int capacidadMaxima,
    bool tieneCosto,
    double precio,
    DateTime? fecha,
    DateTime? horaInicio,
    DateTime? horaFin,
    int duracionMinutos,
    String ciudad,
    String ubicacionNombre,
    double latitud,
    double longitud,
    bool esPublico,
    bool requiereAprobacion,
    String imagenBase64,
    bool esDestacado,
    SponsorTier tipoDestacado,
    int diasDestacado,
    bool puedeDestacar,
    bool isLoading,
    bool isSuccess,
    String? errorMessage,
    String? createdPlanId,
    UserModel? currentUser,
  });

  @override
  $UserModelCopyWith<$Res>? get currentUser;
}

/// @nodoc
class __$$CreatePlanStateImplCopyWithImpl<$Res>
    extends _$CreatePlanStateCopyWithImpl<$Res, _$CreatePlanStateImpl>
    implements _$$CreatePlanStateImplCopyWith<$Res> {
  __$$CreatePlanStateImplCopyWithImpl(
    _$CreatePlanStateImpl _value,
    $Res Function(_$CreatePlanStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreatePlanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? titulo = null,
    Object? descripcion = null,
    Object? categoria = freezed,
    Object? nivelEnergia = null,
    Object? capacidadMaxima = null,
    Object? tieneCosto = null,
    Object? precio = null,
    Object? fecha = freezed,
    Object? horaInicio = freezed,
    Object? horaFin = freezed,
    Object? duracionMinutos = null,
    Object? ciudad = null,
    Object? ubicacionNombre = null,
    Object? latitud = null,
    Object? longitud = null,
    Object? esPublico = null,
    Object? requiereAprobacion = null,
    Object? imagenBase64 = null,
    Object? esDestacado = null,
    Object? tipoDestacado = null,
    Object? diasDestacado = null,
    Object? puedeDestacar = null,
    Object? isLoading = null,
    Object? isSuccess = null,
    Object? errorMessage = freezed,
    Object? createdPlanId = freezed,
    Object? currentUser = freezed,
  }) {
    return _then(
      _$CreatePlanStateImpl(
        currentStep: null == currentStep
            ? _value.currentStep
            : currentStep // ignore: cast_nullable_to_non_nullable
                  as int,
        titulo: null == titulo
            ? _value.titulo
            : titulo // ignore: cast_nullable_to_non_nullable
                  as String,
        descripcion: null == descripcion
            ? _value.descripcion
            : descripcion // ignore: cast_nullable_to_non_nullable
                  as String,
        categoria: freezed == categoria
            ? _value.categoria
            : categoria // ignore: cast_nullable_to_non_nullable
                  as PlanCategory?,
        nivelEnergia: null == nivelEnergia
            ? _value.nivelEnergia
            : nivelEnergia // ignore: cast_nullable_to_non_nullable
                  as EnergyLevel,
        capacidadMaxima: null == capacidadMaxima
            ? _value.capacidadMaxima
            : capacidadMaxima // ignore: cast_nullable_to_non_nullable
                  as int,
        tieneCosto: null == tieneCosto
            ? _value.tieneCosto
            : tieneCosto // ignore: cast_nullable_to_non_nullable
                  as bool,
        precio: null == precio
            ? _value.precio
            : precio // ignore: cast_nullable_to_non_nullable
                  as double,
        fecha: freezed == fecha
            ? _value.fecha
            : fecha // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        horaInicio: freezed == horaInicio
            ? _value.horaInicio
            : horaInicio // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        horaFin: freezed == horaFin
            ? _value.horaFin
            : horaFin // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        duracionMinutos: null == duracionMinutos
            ? _value.duracionMinutos
            : duracionMinutos // ignore: cast_nullable_to_non_nullable
                  as int,
        ciudad: null == ciudad
            ? _value.ciudad
            : ciudad // ignore: cast_nullable_to_non_nullable
                  as String,
        ubicacionNombre: null == ubicacionNombre
            ? _value.ubicacionNombre
            : ubicacionNombre // ignore: cast_nullable_to_non_nullable
                  as String,
        latitud: null == latitud
            ? _value.latitud
            : latitud // ignore: cast_nullable_to_non_nullable
                  as double,
        longitud: null == longitud
            ? _value.longitud
            : longitud // ignore: cast_nullable_to_non_nullable
                  as double,
        esPublico: null == esPublico
            ? _value.esPublico
            : esPublico // ignore: cast_nullable_to_non_nullable
                  as bool,
        requiereAprobacion: null == requiereAprobacion
            ? _value.requiereAprobacion
            : requiereAprobacion // ignore: cast_nullable_to_non_nullable
                  as bool,
        imagenBase64: null == imagenBase64
            ? _value.imagenBase64
            : imagenBase64 // ignore: cast_nullable_to_non_nullable
                  as String,
        esDestacado: null == esDestacado
            ? _value.esDestacado
            : esDestacado // ignore: cast_nullable_to_non_nullable
                  as bool,
        tipoDestacado: null == tipoDestacado
            ? _value.tipoDestacado
            : tipoDestacado // ignore: cast_nullable_to_non_nullable
                  as SponsorTier,
        diasDestacado: null == diasDestacado
            ? _value.diasDestacado
            : diasDestacado // ignore: cast_nullable_to_non_nullable
                  as int,
        puedeDestacar: null == puedeDestacar
            ? _value.puedeDestacar
            : puedeDestacar // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSuccess: null == isSuccess
            ? _value.isSuccess
            : isSuccess // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdPlanId: freezed == createdPlanId
            ? _value.createdPlanId
            : createdPlanId // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentUser: freezed == currentUser
            ? _value.currentUser
            : currentUser // ignore: cast_nullable_to_non_nullable
                  as UserModel?,
      ),
    );
  }
}

/// @nodoc

class _$CreatePlanStateImpl extends _CreatePlanState {
  const _$CreatePlanStateImpl({
    this.currentStep = 0,
    this.titulo = '',
    this.descripcion = '',
    this.categoria = null,
    this.nivelEnergia = EnergyLevel.media,
    this.capacidadMaxima = 5,
    this.tieneCosto = false,
    this.precio = 0.0,
    this.fecha = null,
    this.horaInicio = null,
    this.horaFin = null,
    this.duracionMinutos = 120,
    this.ciudad = '',
    this.ubicacionNombre = '',
    this.latitud = 0.0,
    this.longitud = 0.0,
    this.esPublico = true,
    this.requiereAprobacion = false,
    this.imagenBase64 = '',
    this.esDestacado = false,
    this.tipoDestacado = SponsorTier.none,
    this.diasDestacado = 7,
    this.puedeDestacar = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.createdPlanId,
    this.currentUser,
  }) : super._();

  // Paso actual (0-3)
  @override
  @JsonKey()
  final int currentStep;
  // Step 1: Básico
  @override
  @JsonKey()
  final String titulo;
  @override
  @JsonKey()
  final String descripcion;
  @override
  @JsonKey()
  final PlanCategory? categoria;
  @override
  @JsonKey()
  final EnergyLevel nivelEnergia;
  @override
  @JsonKey()
  final int capacidadMaxima;
  @override
  @JsonKey()
  final bool tieneCosto;
  @override
  @JsonKey()
  final double precio;
  // Step 2: Detalles
  @override
  @JsonKey()
  final DateTime? fecha;
  @override
  @JsonKey()
  final DateTime? horaInicio;
  @override
  @JsonKey()
  final DateTime? horaFin;
  @override
  @JsonKey()
  final int duracionMinutos;
  // Step 3: Ubicación
  @override
  @JsonKey()
  final String ciudad;
  @override
  @JsonKey()
  final String ubicacionNombre;
  @override
  @JsonKey()
  final double latitud;
  @override
  @JsonKey()
  final double longitud;
  // Step 4: Publicar
  @override
  @JsonKey()
  final bool esPublico;
  @override
  @JsonKey()
  final bool requiereAprobacion;
  @override
  @JsonKey()
  final String imagenBase64;
  // === OPCIONES DE DESTACADO (solo negocios) ===
  @override
  @JsonKey()
  final bool esDestacado;
  @override
  @JsonKey()
  final SponsorTier tipoDestacado;
  @override
  @JsonKey()
  final int diasDestacado;
  @override
  @JsonKey()
  final bool puedeDestacar;
  // Estados
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSuccess;
  @override
  final String? errorMessage;
  @override
  final String? createdPlanId;
  // Datos del usuario
  @override
  final UserModel? currentUser;

  @override
  String toString() {
    return 'CreatePlanState(currentStep: $currentStep, titulo: $titulo, descripcion: $descripcion, categoria: $categoria, nivelEnergia: $nivelEnergia, capacidadMaxima: $capacidadMaxima, tieneCosto: $tieneCosto, precio: $precio, fecha: $fecha, horaInicio: $horaInicio, horaFin: $horaFin, duracionMinutos: $duracionMinutos, ciudad: $ciudad, ubicacionNombre: $ubicacionNombre, latitud: $latitud, longitud: $longitud, esPublico: $esPublico, requiereAprobacion: $requiereAprobacion, imagenBase64: $imagenBase64, esDestacado: $esDestacado, tipoDestacado: $tipoDestacado, diasDestacado: $diasDestacado, puedeDestacar: $puedeDestacar, isLoading: $isLoading, isSuccess: $isSuccess, errorMessage: $errorMessage, createdPlanId: $createdPlanId, currentUser: $currentUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatePlanStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.categoria, categoria) ||
                other.categoria == categoria) &&
            (identical(other.nivelEnergia, nivelEnergia) ||
                other.nivelEnergia == nivelEnergia) &&
            (identical(other.capacidadMaxima, capacidadMaxima) ||
                other.capacidadMaxima == capacidadMaxima) &&
            (identical(other.tieneCosto, tieneCosto) ||
                other.tieneCosto == tieneCosto) &&
            (identical(other.precio, precio) || other.precio == precio) &&
            (identical(other.fecha, fecha) || other.fecha == fecha) &&
            (identical(other.horaInicio, horaInicio) ||
                other.horaInicio == horaInicio) &&
            (identical(other.horaFin, horaFin) || other.horaFin == horaFin) &&
            (identical(other.duracionMinutos, duracionMinutos) ||
                other.duracionMinutos == duracionMinutos) &&
            (identical(other.ciudad, ciudad) || other.ciudad == ciudad) &&
            (identical(other.ubicacionNombre, ubicacionNombre) ||
                other.ubicacionNombre == ubicacionNombre) &&
            (identical(other.latitud, latitud) || other.latitud == latitud) &&
            (identical(other.longitud, longitud) ||
                other.longitud == longitud) &&
            (identical(other.esPublico, esPublico) ||
                other.esPublico == esPublico) &&
            (identical(other.requiereAprobacion, requiereAprobacion) ||
                other.requiereAprobacion == requiereAprobacion) &&
            (identical(other.imagenBase64, imagenBase64) ||
                other.imagenBase64 == imagenBase64) &&
            (identical(other.esDestacado, esDestacado) ||
                other.esDestacado == esDestacado) &&
            (identical(other.tipoDestacado, tipoDestacado) ||
                other.tipoDestacado == tipoDestacado) &&
            (identical(other.diasDestacado, diasDestacado) ||
                other.diasDestacado == diasDestacado) &&
            (identical(other.puedeDestacar, puedeDestacar) ||
                other.puedeDestacar == puedeDestacar) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.createdPlanId, createdPlanId) ||
                other.createdPlanId == createdPlanId) &&
            (identical(other.currentUser, currentUser) ||
                other.currentUser == currentUser));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    currentStep,
    titulo,
    descripcion,
    categoria,
    nivelEnergia,
    capacidadMaxima,
    tieneCosto,
    precio,
    fecha,
    horaInicio,
    horaFin,
    duracionMinutos,
    ciudad,
    ubicacionNombre,
    latitud,
    longitud,
    esPublico,
    requiereAprobacion,
    imagenBase64,
    esDestacado,
    tipoDestacado,
    diasDestacado,
    puedeDestacar,
    isLoading,
    isSuccess,
    errorMessage,
    createdPlanId,
    currentUser,
  ]);

  /// Create a copy of CreatePlanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatePlanStateImplCopyWith<_$CreatePlanStateImpl> get copyWith =>
      __$$CreatePlanStateImplCopyWithImpl<_$CreatePlanStateImpl>(
        this,
        _$identity,
      );
}

abstract class _CreatePlanState extends CreatePlanState {
  const factory _CreatePlanState({
    final int currentStep,
    final String titulo,
    final String descripcion,
    final PlanCategory? categoria,
    final EnergyLevel nivelEnergia,
    final int capacidadMaxima,
    final bool tieneCosto,
    final double precio,
    final DateTime? fecha,
    final DateTime? horaInicio,
    final DateTime? horaFin,
    final int duracionMinutos,
    final String ciudad,
    final String ubicacionNombre,
    final double latitud,
    final double longitud,
    final bool esPublico,
    final bool requiereAprobacion,
    final String imagenBase64,
    final bool esDestacado,
    final SponsorTier tipoDestacado,
    final int diasDestacado,
    final bool puedeDestacar,
    final bool isLoading,
    final bool isSuccess,
    final String? errorMessage,
    final String? createdPlanId,
    final UserModel? currentUser,
  }) = _$CreatePlanStateImpl;
  const _CreatePlanState._() : super._();

  // Paso actual (0-3)
  @override
  int get currentStep; // Step 1: Básico
  @override
  String get titulo;
  @override
  String get descripcion;
  @override
  PlanCategory? get categoria;
  @override
  EnergyLevel get nivelEnergia;
  @override
  int get capacidadMaxima;
  @override
  bool get tieneCosto;
  @override
  double get precio; // Step 2: Detalles
  @override
  DateTime? get fecha;
  @override
  DateTime? get horaInicio;
  @override
  DateTime? get horaFin;
  @override
  int get duracionMinutos; // Step 3: Ubicación
  @override
  String get ciudad;
  @override
  String get ubicacionNombre;
  @override
  double get latitud;
  @override
  double get longitud; // Step 4: Publicar
  @override
  bool get esPublico;
  @override
  bool get requiereAprobacion;
  @override
  String get imagenBase64; // === OPCIONES DE DESTACADO (solo negocios) ===
  @override
  bool get esDestacado;
  @override
  SponsorTier get tipoDestacado;
  @override
  int get diasDestacado;
  @override
  bool get puedeDestacar; // Estados
  @override
  bool get isLoading;
  @override
  bool get isSuccess;
  @override
  String? get errorMessage;
  @override
  String? get createdPlanId; // Datos del usuario
  @override
  UserModel? get currentUser;

  /// Create a copy of CreatePlanState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreatePlanStateImplCopyWith<_$CreatePlanStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
