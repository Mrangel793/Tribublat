/// Modelo de metricas de un plan individual
class PlanMetricsModel {
  final String planId;
  final String planTitulo;
  final int impresiones;
  final int clicsDetalle;
  final int intentosUnirse;
  final int conversiones;
  final double ingresosTotales;

  const PlanMetricsModel({
    required this.planId,
    required this.planTitulo,
    this.impresiones = 0,
    this.clicsDetalle = 0,
    this.intentosUnirse = 0,
    this.conversiones = 0,
    this.ingresosTotales = 0.0,
  });

  /// CTR (Click Through Rate) - porcentaje de clics sobre impresiones
  double get ctr {
    if (impresiones == 0) return 0.0;
    return (clicsDetalle / impresiones) * 100;
  }

  /// Tasa de conversion - porcentaje de uniones sobre clics
  double get conversionRate {
    if (clicsDetalle == 0) return 0.0;
    return (conversiones / clicsDetalle) * 100;
  }

  factory PlanMetricsModel.fromMap(Map<String, dynamic> map) {
    return PlanMetricsModel(
      planId: map['id'] ?? '',
      planTitulo: map['titulo'] ?? '',
      impresiones: map['impresiones'] ?? 0,
      clicsDetalle: map['clicsDetalle'] ?? 0,
      intentosUnirse: map['intentosUnirse'] ?? 0,
      conversiones: map['conversiones'] ?? 0,
      ingresosTotales: (map['ingresosTotales'] ?? 0.0).toDouble(),
    );
  }
}

/// Resumen de metricas de todos los planes de un negocio
class BusinessMetricsSummary {
  final int totalPlanes;
  final int planesActivos;
  final int totalImpresiones;
  final int totalConversiones;
  final double ingresosTotales;
  final double tasaConversionPromedio;
  final List<PlanMetricsModel> topPlanes;

  const BusinessMetricsSummary({
    this.totalPlanes = 0,
    this.planesActivos = 0,
    this.totalImpresiones = 0,
    this.totalConversiones = 0,
    this.ingresosTotales = 0.0,
    this.tasaConversionPromedio = 0.0,
    this.topPlanes = const [],
  });
}
