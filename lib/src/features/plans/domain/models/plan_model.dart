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

    // Métricas
    @Default(0) int vistas,
    @Default(0.0) double puntuacionPromedio,
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
}
