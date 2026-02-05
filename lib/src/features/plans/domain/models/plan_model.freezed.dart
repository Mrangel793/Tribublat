// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlanModel _$PlanModelFromJson(Map<String, dynamic> json) {
  return _PlanModel.fromJson(json);
}

/// @nodoc
mixin _$PlanModel {
  String get id => throw _privateConstructorUsedError;
  String get titulo => throw _privateConstructorUsedError;
  String get descripcion => throw _privateConstructorUsedError;
  String get imagenBase64 => throw _privateConstructorUsedError;
  PlanCategory get categoria => throw _privateConstructorUsedError;
  PlanStatus get estado =>
      throw _privateConstructorUsedError; // Organizador (denormalizado para rendimiento)
  String get organizadorId => throw _privateConstructorUsedError;
  String get organizadorNombre => throw _privateConstructorUsedError;
  String get organizadorFoto => throw _privateConstructorUsedError;
  double get organizadorReputacion =>
      throw _privateConstructorUsedError; // Fecha y hora
  DateTime get fechaHora => throw _privateConstructorUsedError;
  DateTime get fechaCreacion => throw _privateConstructorUsedError;
  int get duracionMinutos => throw _privateConstructorUsedError; // Ubicación
  String get ciudad => throw _privateConstructorUsedError;
  String get ubicacionNombre => throw _privateConstructorUsedError;
  double get latitud => throw _privateConstructorUsedError;
  double get longitud => throw _privateConstructorUsedError; // Capacidad
  int get capacidadMaxima => throw _privateConstructorUsedError;
  int get capacidadActual => throw _privateConstructorUsedError;
  List<String> get participantesIds => throw _privateConstructorUsedError;
  List<String> get listaEsperaIds =>
      throw _privateConstructorUsedError; // Nivel de energía requerido
  EnergyLevel get nivelEnergia => throw _privateConstructorUsedError; // Precio
  PlanPriceType get tipoPrecio => throw _privateConstructorUsedError;
  double get precio => throw _privateConstructorUsedError;
  String get moneda =>
      throw _privateConstructorUsedError; // Intereses relacionados (para matching)
  List<String> get interesesRelacionados =>
      throw _privateConstructorUsedError; // Visibilidad
  bool get esPublico => throw _privateConstructorUsedError;
  bool get requiereAprobacion =>
      throw _privateConstructorUsedError; // Restricciones de edad
  int? get edadMinima =>
      throw _privateConstructorUsedError; // Edad minima para participar (ej: 18)
  int? get edadMaxima =>
      throw _privateConstructorUsedError; // Edad maxima para participar (ej: 30)
  // Metricas basicas
  int get vistas => throw _privateConstructorUsedError;
  double get puntuacionPromedio =>
      throw _privateConstructorUsedError; // === PLANES DESTACADOS (solo negocios) ===
  bool get esDestacado => throw _privateConstructorUsedError;
  DateTime? get fechaFinDestacado => throw _privateConstructorUsedError;
  SponsorTier get tipoDestacado =>
      throw _privateConstructorUsedError; // === METRICAS AVANZADAS ===
  int get impresiones => throw _privateConstructorUsedError;
  int get clicsDetalle => throw _privateConstructorUsedError;
  int get intentosUnirse => throw _privateConstructorUsedError;
  int get conversiones =>
      throw _privateConstructorUsedError; // === ROL DEL ORGANIZADOR ===
  UserRole get organizadorRol => throw _privateConstructorUsedError;

  /// Serializes this PlanModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanModelCopyWith<PlanModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanModelCopyWith<$Res> {
  factory $PlanModelCopyWith(PlanModel value, $Res Function(PlanModel) then) =
      _$PlanModelCopyWithImpl<$Res, PlanModel>;
  @useResult
  $Res call({
    String id,
    String titulo,
    String descripcion,
    String imagenBase64,
    PlanCategory categoria,
    PlanStatus estado,
    String organizadorId,
    String organizadorNombre,
    String organizadorFoto,
    double organizadorReputacion,
    DateTime fechaHora,
    DateTime fechaCreacion,
    int duracionMinutos,
    String ciudad,
    String ubicacionNombre,
    double latitud,
    double longitud,
    int capacidadMaxima,
    int capacidadActual,
    List<String> participantesIds,
    List<String> listaEsperaIds,
    EnergyLevel nivelEnergia,
    PlanPriceType tipoPrecio,
    double precio,
    String moneda,
    List<String> interesesRelacionados,
    bool esPublico,
    bool requiereAprobacion,
    int? edadMinima,
    int? edadMaxima,
    int vistas,
    double puntuacionPromedio,
    bool esDestacado,
    DateTime? fechaFinDestacado,
    SponsorTier tipoDestacado,
    int impresiones,
    int clicsDetalle,
    int intentosUnirse,
    int conversiones,
    UserRole organizadorRol,
  });
}

/// @nodoc
class _$PlanModelCopyWithImpl<$Res, $Val extends PlanModel>
    implements $PlanModelCopyWith<$Res> {
  _$PlanModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titulo = null,
    Object? descripcion = null,
    Object? imagenBase64 = null,
    Object? categoria = null,
    Object? estado = null,
    Object? organizadorId = null,
    Object? organizadorNombre = null,
    Object? organizadorFoto = null,
    Object? organizadorReputacion = null,
    Object? fechaHora = null,
    Object? fechaCreacion = null,
    Object? duracionMinutos = null,
    Object? ciudad = null,
    Object? ubicacionNombre = null,
    Object? latitud = null,
    Object? longitud = null,
    Object? capacidadMaxima = null,
    Object? capacidadActual = null,
    Object? participantesIds = null,
    Object? listaEsperaIds = null,
    Object? nivelEnergia = null,
    Object? tipoPrecio = null,
    Object? precio = null,
    Object? moneda = null,
    Object? interesesRelacionados = null,
    Object? esPublico = null,
    Object? requiereAprobacion = null,
    Object? edadMinima = freezed,
    Object? edadMaxima = freezed,
    Object? vistas = null,
    Object? puntuacionPromedio = null,
    Object? esDestacado = null,
    Object? fechaFinDestacado = freezed,
    Object? tipoDestacado = null,
    Object? impresiones = null,
    Object? clicsDetalle = null,
    Object? intentosUnirse = null,
    Object? conversiones = null,
    Object? organizadorRol = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            titulo: null == titulo
                ? _value.titulo
                : titulo // ignore: cast_nullable_to_non_nullable
                      as String,
            descripcion: null == descripcion
                ? _value.descripcion
                : descripcion // ignore: cast_nullable_to_non_nullable
                      as String,
            imagenBase64: null == imagenBase64
                ? _value.imagenBase64
                : imagenBase64 // ignore: cast_nullable_to_non_nullable
                      as String,
            categoria: null == categoria
                ? _value.categoria
                : categoria // ignore: cast_nullable_to_non_nullable
                      as PlanCategory,
            estado: null == estado
                ? _value.estado
                : estado // ignore: cast_nullable_to_non_nullable
                      as PlanStatus,
            organizadorId: null == organizadorId
                ? _value.organizadorId
                : organizadorId // ignore: cast_nullable_to_non_nullable
                      as String,
            organizadorNombre: null == organizadorNombre
                ? _value.organizadorNombre
                : organizadorNombre // ignore: cast_nullable_to_non_nullable
                      as String,
            organizadorFoto: null == organizadorFoto
                ? _value.organizadorFoto
                : organizadorFoto // ignore: cast_nullable_to_non_nullable
                      as String,
            organizadorReputacion: null == organizadorReputacion
                ? _value.organizadorReputacion
                : organizadorReputacion // ignore: cast_nullable_to_non_nullable
                      as double,
            fechaHora: null == fechaHora
                ? _value.fechaHora
                : fechaHora // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            fechaCreacion: null == fechaCreacion
                ? _value.fechaCreacion
                : fechaCreacion // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
            capacidadMaxima: null == capacidadMaxima
                ? _value.capacidadMaxima
                : capacidadMaxima // ignore: cast_nullable_to_non_nullable
                      as int,
            capacidadActual: null == capacidadActual
                ? _value.capacidadActual
                : capacidadActual // ignore: cast_nullable_to_non_nullable
                      as int,
            participantesIds: null == participantesIds
                ? _value.participantesIds
                : participantesIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            listaEsperaIds: null == listaEsperaIds
                ? _value.listaEsperaIds
                : listaEsperaIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            nivelEnergia: null == nivelEnergia
                ? _value.nivelEnergia
                : nivelEnergia // ignore: cast_nullable_to_non_nullable
                      as EnergyLevel,
            tipoPrecio: null == tipoPrecio
                ? _value.tipoPrecio
                : tipoPrecio // ignore: cast_nullable_to_non_nullable
                      as PlanPriceType,
            precio: null == precio
                ? _value.precio
                : precio // ignore: cast_nullable_to_non_nullable
                      as double,
            moneda: null == moneda
                ? _value.moneda
                : moneda // ignore: cast_nullable_to_non_nullable
                      as String,
            interesesRelacionados: null == interesesRelacionados
                ? _value.interesesRelacionados
                : interesesRelacionados // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            esPublico: null == esPublico
                ? _value.esPublico
                : esPublico // ignore: cast_nullable_to_non_nullable
                      as bool,
            requiereAprobacion: null == requiereAprobacion
                ? _value.requiereAprobacion
                : requiereAprobacion // ignore: cast_nullable_to_non_nullable
                      as bool,
            edadMinima: freezed == edadMinima
                ? _value.edadMinima
                : edadMinima // ignore: cast_nullable_to_non_nullable
                      as int?,
            edadMaxima: freezed == edadMaxima
                ? _value.edadMaxima
                : edadMaxima // ignore: cast_nullable_to_non_nullable
                      as int?,
            vistas: null == vistas
                ? _value.vistas
                : vistas // ignore: cast_nullable_to_non_nullable
                      as int,
            puntuacionPromedio: null == puntuacionPromedio
                ? _value.puntuacionPromedio
                : puntuacionPromedio // ignore: cast_nullable_to_non_nullable
                      as double,
            esDestacado: null == esDestacado
                ? _value.esDestacado
                : esDestacado // ignore: cast_nullable_to_non_nullable
                      as bool,
            fechaFinDestacado: freezed == fechaFinDestacado
                ? _value.fechaFinDestacado
                : fechaFinDestacado // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            tipoDestacado: null == tipoDestacado
                ? _value.tipoDestacado
                : tipoDestacado // ignore: cast_nullable_to_non_nullable
                      as SponsorTier,
            impresiones: null == impresiones
                ? _value.impresiones
                : impresiones // ignore: cast_nullable_to_non_nullable
                      as int,
            clicsDetalle: null == clicsDetalle
                ? _value.clicsDetalle
                : clicsDetalle // ignore: cast_nullable_to_non_nullable
                      as int,
            intentosUnirse: null == intentosUnirse
                ? _value.intentosUnirse
                : intentosUnirse // ignore: cast_nullable_to_non_nullable
                      as int,
            conversiones: null == conversiones
                ? _value.conversiones
                : conversiones // ignore: cast_nullable_to_non_nullable
                      as int,
            organizadorRol: null == organizadorRol
                ? _value.organizadorRol
                : organizadorRol // ignore: cast_nullable_to_non_nullable
                      as UserRole,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlanModelImplCopyWith<$Res>
    implements $PlanModelCopyWith<$Res> {
  factory _$$PlanModelImplCopyWith(
    _$PlanModelImpl value,
    $Res Function(_$PlanModelImpl) then,
  ) = __$$PlanModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String titulo,
    String descripcion,
    String imagenBase64,
    PlanCategory categoria,
    PlanStatus estado,
    String organizadorId,
    String organizadorNombre,
    String organizadorFoto,
    double organizadorReputacion,
    DateTime fechaHora,
    DateTime fechaCreacion,
    int duracionMinutos,
    String ciudad,
    String ubicacionNombre,
    double latitud,
    double longitud,
    int capacidadMaxima,
    int capacidadActual,
    List<String> participantesIds,
    List<String> listaEsperaIds,
    EnergyLevel nivelEnergia,
    PlanPriceType tipoPrecio,
    double precio,
    String moneda,
    List<String> interesesRelacionados,
    bool esPublico,
    bool requiereAprobacion,
    int? edadMinima,
    int? edadMaxima,
    int vistas,
    double puntuacionPromedio,
    bool esDestacado,
    DateTime? fechaFinDestacado,
    SponsorTier tipoDestacado,
    int impresiones,
    int clicsDetalle,
    int intentosUnirse,
    int conversiones,
    UserRole organizadorRol,
  });
}

/// @nodoc
class __$$PlanModelImplCopyWithImpl<$Res>
    extends _$PlanModelCopyWithImpl<$Res, _$PlanModelImpl>
    implements _$$PlanModelImplCopyWith<$Res> {
  __$$PlanModelImplCopyWithImpl(
    _$PlanModelImpl _value,
    $Res Function(_$PlanModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titulo = null,
    Object? descripcion = null,
    Object? imagenBase64 = null,
    Object? categoria = null,
    Object? estado = null,
    Object? organizadorId = null,
    Object? organizadorNombre = null,
    Object? organizadorFoto = null,
    Object? organizadorReputacion = null,
    Object? fechaHora = null,
    Object? fechaCreacion = null,
    Object? duracionMinutos = null,
    Object? ciudad = null,
    Object? ubicacionNombre = null,
    Object? latitud = null,
    Object? longitud = null,
    Object? capacidadMaxima = null,
    Object? capacidadActual = null,
    Object? participantesIds = null,
    Object? listaEsperaIds = null,
    Object? nivelEnergia = null,
    Object? tipoPrecio = null,
    Object? precio = null,
    Object? moneda = null,
    Object? interesesRelacionados = null,
    Object? esPublico = null,
    Object? requiereAprobacion = null,
    Object? edadMinima = freezed,
    Object? edadMaxima = freezed,
    Object? vistas = null,
    Object? puntuacionPromedio = null,
    Object? esDestacado = null,
    Object? fechaFinDestacado = freezed,
    Object? tipoDestacado = null,
    Object? impresiones = null,
    Object? clicsDetalle = null,
    Object? intentosUnirse = null,
    Object? conversiones = null,
    Object? organizadorRol = null,
  }) {
    return _then(
      _$PlanModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        titulo: null == titulo
            ? _value.titulo
            : titulo // ignore: cast_nullable_to_non_nullable
                  as String,
        descripcion: null == descripcion
            ? _value.descripcion
            : descripcion // ignore: cast_nullable_to_non_nullable
                  as String,
        imagenBase64: null == imagenBase64
            ? _value.imagenBase64
            : imagenBase64 // ignore: cast_nullable_to_non_nullable
                  as String,
        categoria: null == categoria
            ? _value.categoria
            : categoria // ignore: cast_nullable_to_non_nullable
                  as PlanCategory,
        estado: null == estado
            ? _value.estado
            : estado // ignore: cast_nullable_to_non_nullable
                  as PlanStatus,
        organizadorId: null == organizadorId
            ? _value.organizadorId
            : organizadorId // ignore: cast_nullable_to_non_nullable
                  as String,
        organizadorNombre: null == organizadorNombre
            ? _value.organizadorNombre
            : organizadorNombre // ignore: cast_nullable_to_non_nullable
                  as String,
        organizadorFoto: null == organizadorFoto
            ? _value.organizadorFoto
            : organizadorFoto // ignore: cast_nullable_to_non_nullable
                  as String,
        organizadorReputacion: null == organizadorReputacion
            ? _value.organizadorReputacion
            : organizadorReputacion // ignore: cast_nullable_to_non_nullable
                  as double,
        fechaHora: null == fechaHora
            ? _value.fechaHora
            : fechaHora // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        fechaCreacion: null == fechaCreacion
            ? _value.fechaCreacion
            : fechaCreacion // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
        capacidadMaxima: null == capacidadMaxima
            ? _value.capacidadMaxima
            : capacidadMaxima // ignore: cast_nullable_to_non_nullable
                  as int,
        capacidadActual: null == capacidadActual
            ? _value.capacidadActual
            : capacidadActual // ignore: cast_nullable_to_non_nullable
                  as int,
        participantesIds: null == participantesIds
            ? _value._participantesIds
            : participantesIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        listaEsperaIds: null == listaEsperaIds
            ? _value._listaEsperaIds
            : listaEsperaIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        nivelEnergia: null == nivelEnergia
            ? _value.nivelEnergia
            : nivelEnergia // ignore: cast_nullable_to_non_nullable
                  as EnergyLevel,
        tipoPrecio: null == tipoPrecio
            ? _value.tipoPrecio
            : tipoPrecio // ignore: cast_nullable_to_non_nullable
                  as PlanPriceType,
        precio: null == precio
            ? _value.precio
            : precio // ignore: cast_nullable_to_non_nullable
                  as double,
        moneda: null == moneda
            ? _value.moneda
            : moneda // ignore: cast_nullable_to_non_nullable
                  as String,
        interesesRelacionados: null == interesesRelacionados
            ? _value._interesesRelacionados
            : interesesRelacionados // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        esPublico: null == esPublico
            ? _value.esPublico
            : esPublico // ignore: cast_nullable_to_non_nullable
                  as bool,
        requiereAprobacion: null == requiereAprobacion
            ? _value.requiereAprobacion
            : requiereAprobacion // ignore: cast_nullable_to_non_nullable
                  as bool,
        edadMinima: freezed == edadMinima
            ? _value.edadMinima
            : edadMinima // ignore: cast_nullable_to_non_nullable
                  as int?,
        edadMaxima: freezed == edadMaxima
            ? _value.edadMaxima
            : edadMaxima // ignore: cast_nullable_to_non_nullable
                  as int?,
        vistas: null == vistas
            ? _value.vistas
            : vistas // ignore: cast_nullable_to_non_nullable
                  as int,
        puntuacionPromedio: null == puntuacionPromedio
            ? _value.puntuacionPromedio
            : puntuacionPromedio // ignore: cast_nullable_to_non_nullable
                  as double,
        esDestacado: null == esDestacado
            ? _value.esDestacado
            : esDestacado // ignore: cast_nullable_to_non_nullable
                  as bool,
        fechaFinDestacado: freezed == fechaFinDestacado
            ? _value.fechaFinDestacado
            : fechaFinDestacado // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        tipoDestacado: null == tipoDestacado
            ? _value.tipoDestacado
            : tipoDestacado // ignore: cast_nullable_to_non_nullable
                  as SponsorTier,
        impresiones: null == impresiones
            ? _value.impresiones
            : impresiones // ignore: cast_nullable_to_non_nullable
                  as int,
        clicsDetalle: null == clicsDetalle
            ? _value.clicsDetalle
            : clicsDetalle // ignore: cast_nullable_to_non_nullable
                  as int,
        intentosUnirse: null == intentosUnirse
            ? _value.intentosUnirse
            : intentosUnirse // ignore: cast_nullable_to_non_nullable
                  as int,
        conversiones: null == conversiones
            ? _value.conversiones
            : conversiones // ignore: cast_nullable_to_non_nullable
                  as int,
        organizadorRol: null == organizadorRol
            ? _value.organizadorRol
            : organizadorRol // ignore: cast_nullable_to_non_nullable
                  as UserRole,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanModelImpl extends _PlanModel {
  const _$PlanModelImpl({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.imagenBase64 = '',
    required this.categoria,
    this.estado = PlanStatus.activo,
    required this.organizadorId,
    required this.organizadorNombre,
    this.organizadorFoto = '',
    this.organizadorReputacion = 0.0,
    required this.fechaHora,
    required this.fechaCreacion,
    this.duracionMinutos = 120,
    required this.ciudad,
    this.ubicacionNombre = '',
    this.latitud = 0.0,
    this.longitud = 0.0,
    required this.capacidadMaxima,
    this.capacidadActual = 0,
    final List<String> participantesIds = const [],
    final List<String> listaEsperaIds = const [],
    this.nivelEnergia = EnergyLevel.media,
    this.tipoPrecio = PlanPriceType.gratis,
    this.precio = 0.0,
    this.moneda = 'COP',
    final List<String> interesesRelacionados = const [],
    this.esPublico = true,
    this.requiereAprobacion = false,
    this.edadMinima,
    this.edadMaxima,
    this.vistas = 0,
    this.puntuacionPromedio = 0.0,
    this.esDestacado = false,
    this.fechaFinDestacado,
    this.tipoDestacado = SponsorTier.none,
    this.impresiones = 0,
    this.clicsDetalle = 0,
    this.intentosUnirse = 0,
    this.conversiones = 0,
    this.organizadorRol = UserRole.usuario,
  }) : _participantesIds = participantesIds,
       _listaEsperaIds = listaEsperaIds,
       _interesesRelacionados = interesesRelacionados,
       super._();

  factory _$PlanModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanModelImplFromJson(json);

  @override
  final String id;
  @override
  final String titulo;
  @override
  final String descripcion;
  @override
  @JsonKey()
  final String imagenBase64;
  @override
  final PlanCategory categoria;
  @override
  @JsonKey()
  final PlanStatus estado;
  // Organizador (denormalizado para rendimiento)
  @override
  final String organizadorId;
  @override
  final String organizadorNombre;
  @override
  @JsonKey()
  final String organizadorFoto;
  @override
  @JsonKey()
  final double organizadorReputacion;
  // Fecha y hora
  @override
  final DateTime fechaHora;
  @override
  final DateTime fechaCreacion;
  @override
  @JsonKey()
  final int duracionMinutos;
  // Ubicación
  @override
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
  // Capacidad
  @override
  final int capacidadMaxima;
  @override
  @JsonKey()
  final int capacidadActual;
  final List<String> _participantesIds;
  @override
  @JsonKey()
  List<String> get participantesIds {
    if (_participantesIds is EqualUnmodifiableListView)
      return _participantesIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantesIds);
  }

  final List<String> _listaEsperaIds;
  @override
  @JsonKey()
  List<String> get listaEsperaIds {
    if (_listaEsperaIds is EqualUnmodifiableListView) return _listaEsperaIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_listaEsperaIds);
  }

  // Nivel de energía requerido
  @override
  @JsonKey()
  final EnergyLevel nivelEnergia;
  // Precio
  @override
  @JsonKey()
  final PlanPriceType tipoPrecio;
  @override
  @JsonKey()
  final double precio;
  @override
  @JsonKey()
  final String moneda;
  // Intereses relacionados (para matching)
  final List<String> _interesesRelacionados;
  // Intereses relacionados (para matching)
  @override
  @JsonKey()
  List<String> get interesesRelacionados {
    if (_interesesRelacionados is EqualUnmodifiableListView)
      return _interesesRelacionados;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interesesRelacionados);
  }

  // Visibilidad
  @override
  @JsonKey()
  final bool esPublico;
  @override
  @JsonKey()
  final bool requiereAprobacion;
  // Restricciones de edad
  @override
  final int? edadMinima;
  // Edad minima para participar (ej: 18)
  @override
  final int? edadMaxima;
  // Edad maxima para participar (ej: 30)
  // Metricas basicas
  @override
  @JsonKey()
  final int vistas;
  @override
  @JsonKey()
  final double puntuacionPromedio;
  // === PLANES DESTACADOS (solo negocios) ===
  @override
  @JsonKey()
  final bool esDestacado;
  @override
  final DateTime? fechaFinDestacado;
  @override
  @JsonKey()
  final SponsorTier tipoDestacado;
  // === METRICAS AVANZADAS ===
  @override
  @JsonKey()
  final int impresiones;
  @override
  @JsonKey()
  final int clicsDetalle;
  @override
  @JsonKey()
  final int intentosUnirse;
  @override
  @JsonKey()
  final int conversiones;
  // === ROL DEL ORGANIZADOR ===
  @override
  @JsonKey()
  final UserRole organizadorRol;

  @override
  String toString() {
    return 'PlanModel(id: $id, titulo: $titulo, descripcion: $descripcion, imagenBase64: $imagenBase64, categoria: $categoria, estado: $estado, organizadorId: $organizadorId, organizadorNombre: $organizadorNombre, organizadorFoto: $organizadorFoto, organizadorReputacion: $organizadorReputacion, fechaHora: $fechaHora, fechaCreacion: $fechaCreacion, duracionMinutos: $duracionMinutos, ciudad: $ciudad, ubicacionNombre: $ubicacionNombre, latitud: $latitud, longitud: $longitud, capacidadMaxima: $capacidadMaxima, capacidadActual: $capacidadActual, participantesIds: $participantesIds, listaEsperaIds: $listaEsperaIds, nivelEnergia: $nivelEnergia, tipoPrecio: $tipoPrecio, precio: $precio, moneda: $moneda, interesesRelacionados: $interesesRelacionados, esPublico: $esPublico, requiereAprobacion: $requiereAprobacion, edadMinima: $edadMinima, edadMaxima: $edadMaxima, vistas: $vistas, puntuacionPromedio: $puntuacionPromedio, esDestacado: $esDestacado, fechaFinDestacado: $fechaFinDestacado, tipoDestacado: $tipoDestacado, impresiones: $impresiones, clicsDetalle: $clicsDetalle, intentosUnirse: $intentosUnirse, conversiones: $conversiones, organizadorRol: $organizadorRol)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.imagenBase64, imagenBase64) ||
                other.imagenBase64 == imagenBase64) &&
            (identical(other.categoria, categoria) ||
                other.categoria == categoria) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.organizadorId, organizadorId) ||
                other.organizadorId == organizadorId) &&
            (identical(other.organizadorNombre, organizadorNombre) ||
                other.organizadorNombre == organizadorNombre) &&
            (identical(other.organizadorFoto, organizadorFoto) ||
                other.organizadorFoto == organizadorFoto) &&
            (identical(other.organizadorReputacion, organizadorReputacion) ||
                other.organizadorReputacion == organizadorReputacion) &&
            (identical(other.fechaHora, fechaHora) ||
                other.fechaHora == fechaHora) &&
            (identical(other.fechaCreacion, fechaCreacion) ||
                other.fechaCreacion == fechaCreacion) &&
            (identical(other.duracionMinutos, duracionMinutos) ||
                other.duracionMinutos == duracionMinutos) &&
            (identical(other.ciudad, ciudad) || other.ciudad == ciudad) &&
            (identical(other.ubicacionNombre, ubicacionNombre) ||
                other.ubicacionNombre == ubicacionNombre) &&
            (identical(other.latitud, latitud) || other.latitud == latitud) &&
            (identical(other.longitud, longitud) ||
                other.longitud == longitud) &&
            (identical(other.capacidadMaxima, capacidadMaxima) ||
                other.capacidadMaxima == capacidadMaxima) &&
            (identical(other.capacidadActual, capacidadActual) ||
                other.capacidadActual == capacidadActual) &&
            const DeepCollectionEquality().equals(
              other._participantesIds,
              _participantesIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._listaEsperaIds,
              _listaEsperaIds,
            ) &&
            (identical(other.nivelEnergia, nivelEnergia) ||
                other.nivelEnergia == nivelEnergia) &&
            (identical(other.tipoPrecio, tipoPrecio) ||
                other.tipoPrecio == tipoPrecio) &&
            (identical(other.precio, precio) || other.precio == precio) &&
            (identical(other.moneda, moneda) || other.moneda == moneda) &&
            const DeepCollectionEquality().equals(
              other._interesesRelacionados,
              _interesesRelacionados,
            ) &&
            (identical(other.esPublico, esPublico) ||
                other.esPublico == esPublico) &&
            (identical(other.requiereAprobacion, requiereAprobacion) ||
                other.requiereAprobacion == requiereAprobacion) &&
            (identical(other.edadMinima, edadMinima) ||
                other.edadMinima == edadMinima) &&
            (identical(other.edadMaxima, edadMaxima) ||
                other.edadMaxima == edadMaxima) &&
            (identical(other.vistas, vistas) || other.vistas == vistas) &&
            (identical(other.puntuacionPromedio, puntuacionPromedio) ||
                other.puntuacionPromedio == puntuacionPromedio) &&
            (identical(other.esDestacado, esDestacado) ||
                other.esDestacado == esDestacado) &&
            (identical(other.fechaFinDestacado, fechaFinDestacado) ||
                other.fechaFinDestacado == fechaFinDestacado) &&
            (identical(other.tipoDestacado, tipoDestacado) ||
                other.tipoDestacado == tipoDestacado) &&
            (identical(other.impresiones, impresiones) ||
                other.impresiones == impresiones) &&
            (identical(other.clicsDetalle, clicsDetalle) ||
                other.clicsDetalle == clicsDetalle) &&
            (identical(other.intentosUnirse, intentosUnirse) ||
                other.intentosUnirse == intentosUnirse) &&
            (identical(other.conversiones, conversiones) ||
                other.conversiones == conversiones) &&
            (identical(other.organizadorRol, organizadorRol) ||
                other.organizadorRol == organizadorRol));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    titulo,
    descripcion,
    imagenBase64,
    categoria,
    estado,
    organizadorId,
    organizadorNombre,
    organizadorFoto,
    organizadorReputacion,
    fechaHora,
    fechaCreacion,
    duracionMinutos,
    ciudad,
    ubicacionNombre,
    latitud,
    longitud,
    capacidadMaxima,
    capacidadActual,
    const DeepCollectionEquality().hash(_participantesIds),
    const DeepCollectionEquality().hash(_listaEsperaIds),
    nivelEnergia,
    tipoPrecio,
    precio,
    moneda,
    const DeepCollectionEquality().hash(_interesesRelacionados),
    esPublico,
    requiereAprobacion,
    edadMinima,
    edadMaxima,
    vistas,
    puntuacionPromedio,
    esDestacado,
    fechaFinDestacado,
    tipoDestacado,
    impresiones,
    clicsDetalle,
    intentosUnirse,
    conversiones,
    organizadorRol,
  ]);

  /// Create a copy of PlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanModelImplCopyWith<_$PlanModelImpl> get copyWith =>
      __$$PlanModelImplCopyWithImpl<_$PlanModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanModelImplToJson(this);
  }
}

abstract class _PlanModel extends PlanModel {
  const factory _PlanModel({
    required final String id,
    required final String titulo,
    required final String descripcion,
    final String imagenBase64,
    required final PlanCategory categoria,
    final PlanStatus estado,
    required final String organizadorId,
    required final String organizadorNombre,
    final String organizadorFoto,
    final double organizadorReputacion,
    required final DateTime fechaHora,
    required final DateTime fechaCreacion,
    final int duracionMinutos,
    required final String ciudad,
    final String ubicacionNombre,
    final double latitud,
    final double longitud,
    required final int capacidadMaxima,
    final int capacidadActual,
    final List<String> participantesIds,
    final List<String> listaEsperaIds,
    final EnergyLevel nivelEnergia,
    final PlanPriceType tipoPrecio,
    final double precio,
    final String moneda,
    final List<String> interesesRelacionados,
    final bool esPublico,
    final bool requiereAprobacion,
    final int? edadMinima,
    final int? edadMaxima,
    final int vistas,
    final double puntuacionPromedio,
    final bool esDestacado,
    final DateTime? fechaFinDestacado,
    final SponsorTier tipoDestacado,
    final int impresiones,
    final int clicsDetalle,
    final int intentosUnirse,
    final int conversiones,
    final UserRole organizadorRol,
  }) = _$PlanModelImpl;
  const _PlanModel._() : super._();

  factory _PlanModel.fromJson(Map<String, dynamic> json) =
      _$PlanModelImpl.fromJson;

  @override
  String get id;
  @override
  String get titulo;
  @override
  String get descripcion;
  @override
  String get imagenBase64;
  @override
  PlanCategory get categoria;
  @override
  PlanStatus get estado; // Organizador (denormalizado para rendimiento)
  @override
  String get organizadorId;
  @override
  String get organizadorNombre;
  @override
  String get organizadorFoto;
  @override
  double get organizadorReputacion; // Fecha y hora
  @override
  DateTime get fechaHora;
  @override
  DateTime get fechaCreacion;
  @override
  int get duracionMinutos; // Ubicación
  @override
  String get ciudad;
  @override
  String get ubicacionNombre;
  @override
  double get latitud;
  @override
  double get longitud; // Capacidad
  @override
  int get capacidadMaxima;
  @override
  int get capacidadActual;
  @override
  List<String> get participantesIds;
  @override
  List<String> get listaEsperaIds; // Nivel de energía requerido
  @override
  EnergyLevel get nivelEnergia; // Precio
  @override
  PlanPriceType get tipoPrecio;
  @override
  double get precio;
  @override
  String get moneda; // Intereses relacionados (para matching)
  @override
  List<String> get interesesRelacionados; // Visibilidad
  @override
  bool get esPublico;
  @override
  bool get requiereAprobacion; // Restricciones de edad
  @override
  int? get edadMinima; // Edad minima para participar (ej: 18)
  @override
  int? get edadMaxima; // Edad maxima para participar (ej: 30)
  // Metricas basicas
  @override
  int get vistas;
  @override
  double get puntuacionPromedio; // === PLANES DESTACADOS (solo negocios) ===
  @override
  bool get esDestacado;
  @override
  DateTime? get fechaFinDestacado;
  @override
  SponsorTier get tipoDestacado; // === METRICAS AVANZADAS ===
  @override
  int get impresiones;
  @override
  int get clicsDetalle;
  @override
  int get intentosUnirse;
  @override
  int get conversiones; // === ROL DEL ORGANIZADOR ===
  @override
  UserRole get organizadorRol;

  /// Create a copy of PlanModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanModelImplCopyWith<_$PlanModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
