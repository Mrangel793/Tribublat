import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

part 'plan_model.freezed.dart';
part 'plan_model.g.dart';

@freezed
class PlanModel with _$PlanModel {
  const PlanModel._();

  const factory PlanModel({
    required String id,
    required String titulo,
    required String descripcion,
    @Default('') String imagenBase64,
    required PlanCategory categoria,
    @Default(PlanStatus.activo) PlanStatus estado,

    // Organizador (denormalizado para rendimiento)
    required String organizadorId,
    required String organizadorNombre,
    @Default('') String organizadorFoto,
    @Default(0.0) double organizadorReputacion,

    // Fecha y hora
    required DateTime fechaHora,
    required DateTime fechaCreacion,
    @Default(120) int duracionMinutos,

    // Ubicación
    required String ciudad,
    @Default('') String ubicacionNombre,
    @Default(0.0) double latitud,
    @Default(0.0) double longitud,

    // Capacidad
    required int capacidadMaxima,
    @Default(0) int capacidadActual,
    @Default([]) List<String> participantesIds,
    @Default([]) List<String> listaEsperaIds,

    // Nivel de energía requerido
    @Default(EnergyLevel.media) EnergyLevel nivelEnergia,

    // Precio
    @Default(PlanPriceType.gratis) PlanPriceType tipoPrecio,
    @Default(0.0) double precio,
    @Default('COP') String moneda,

    // Intereses relacionados (para matching)
    @Default([]) List<String> interesesRelacionados,

    // Visibilidad
    @Default(true) bool esPublico,
    @Default(false) bool requiereAprobacion,

    // Restricciones de edad
    int? edadMinima,    // Edad minima para participar (ej: 18)
    int? edadMaxima,    // Edad maxima para participar (ej: 30)

    // Metricas basicas
    @Default(0) int vistas,
    @Default(0.0) double puntuacionPromedio,

    // === PLANES DESTACADOS (solo negocios) ===
    @Default(false) bool esDestacado,
    DateTime? fechaFinDestacado,
    @Default(SponsorTier.none) SponsorTier tipoDestacado,

    // === METRICAS AVANZADAS ===
    @Default(0) int impresiones,
    @Default(0) int clicsDetalle,
    @Default(0) int intentosUnirse,
    @Default(0) int conversiones,

    // === ROL DEL ORGANIZADOR ===
    @Default(UserRole.usuario) UserRole organizadorRol,
  }) = _PlanModel;

  factory PlanModel.fromJson(Map<String, dynamic> json) =>
      _$PlanModelFromJson(json);

  /// Indica si el plan tiene disponibilidad
  bool get tieneDisponibilidad => capacidadActual < capacidadMaxima;

  /// Número de plazas disponibles
  int get plazasDisponibles => capacidadMaxima - capacidadActual;

  /// Formato de capacidad "12/15 plazas"
  String get capacidadFormateada => '$capacidadActual/$capacidadMaxima plazas';

  /// Precio formateado
  String get precioFormateado {
    if (tipoPrecio == PlanPriceType.gratis) return 'Gratis';
    return '\$${precio.toStringAsFixed(precio.truncateToDouble() == precio ? 0 : 2)}';
  }

  /// Verifica si el plan es hoy
  bool get esHoy {
    final now = DateTime.now();
    return fechaHora.year == now.year &&
        fechaHora.month == now.month &&
        fechaHora.day == now.day;
  }

  /// Verifica si el plan es instantáneo (inicia en menos de 2 horas)
  bool get esInstantaneo {
    final now = DateTime.now();
    final diff = fechaHora.difference(now);
    return diff.inMinutes <= 120 && diff.inMinutes >= 0;
  }

  /// Verifica si el plan ya pasó
  bool get yaPaso => fechaHora.isBefore(DateTime.now());

  /// Verifica si un usuario está en el plan
  bool isUserParticipant(String userId) => participantesIds.contains(userId);

  /// Verifica si un usuario está en lista de espera
  bool isUserInWaitingList(String userId) => listaEsperaIds.contains(userId);

  // === METODOS DE PLANES DESTACADOS ===

  /// Indica si el plan esta activamente destacado
  bool get estaDestacadoActivo {
    if (!esDestacado) return false;
    if (fechaFinDestacado == null) return true;
    return fechaFinDestacado!.isAfter(DateTime.now());
  }

  /// Dias restantes de destacado
  int get diasRestantesDestacado {
    if (!estaDestacadoActivo || fechaFinDestacado == null) return 0;
    return fechaFinDestacado!.difference(DateTime.now()).inDays;
  }

  // === METODOS DE METRICAS ===

  /// CTR (Click Through Rate) - porcentaje de clics sobre impresiones
  double get ctr {
    if (impresiones == 0) return 0.0;
    return (clicsDetalle / impresiones) * 100;
  }

  /// Tasa de conversion - porcentaje de uniones sobre clics
  double get tasaConversion {
    if (clicsDetalle == 0) return 0.0;
    return (conversiones / clicsDetalle) * 100;
  }

  /// Indica si el organizador es un negocio
  bool get esDeNegocio =>
      organizadorRol == UserRole.negocio || organizadorRol == UserRole.admin;

  // === METODOS DE RESTRICCION DE EDAD ===

  /// Indica si el plan tiene restriccion de edad
  bool get tieneRestriccionEdad => edadMinima != null || edadMaxima != null;

  /// Formato de restriccion de edad
  String get restriccionEdadFormateada {
    if (!tieneRestriccionEdad) return 'Sin restriccion';
    if (edadMinima != null && edadMaxima != null) {
      return '$edadMinima-$edadMaxima anos';
    }
    if (edadMinima != null) return '+$edadMinima anos';
    if (edadMaxima != null) return 'Hasta $edadMaxima anos';
    return 'Sin restriccion';
  }

  /// Verifica si una persona de cierta edad puede participar
  bool puedeParticipar(int edad) {
    if (edadMinima != null && edad < edadMinima!) return false;
    if (edadMaxima != null && edad > edadMaxima!) return false;
    return true;
  }

  /// Verifica si el plan es para un rango de edad especifico
  bool estaEnRangoEdad(int? minAge, int? maxAge) {
    if (minAge == null && maxAge == null) return true;

    // Si el plan no tiene restricciones, aplica a todos los rangos
    if (!tieneRestriccionEdad) return true;

    // Verificar superposicion de rangos
    final planMin = edadMinima ?? 0;
    final planMax = edadMaxima ?? 999;
    final filterMin = minAge ?? 0;
    final filterMax = maxAge ?? 999;

    return planMin <= filterMax && planMax >= filterMin;
  }
}
