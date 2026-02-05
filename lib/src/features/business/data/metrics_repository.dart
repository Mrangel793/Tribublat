import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/business/domain/plan_metrics_model.dart';

/// Repositorio para operaciones de metricas de planes
class MetricsRepository {
  final FirebaseFirestore _firestore;

  MetricsRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _plansRef =>
      _firestore.collection('plans');

  /// Obtiene las metricas de un plan especifico
  Future<PlanMetricsModel?> getPlanMetrics(String planId) async {
    final planDoc = await _plansRef.doc(planId).get();
    if (!planDoc.exists) return null;

    final data = planDoc.data()!;
    return PlanMetricsModel.fromMap({...data, 'id': planDoc.id});
  }

  /// Obtiene el resumen de metricas para un negocio
  Future<BusinessMetricsSummary> getBusinessMetrics(String userId) async {
    final plansSnapshot = await _plansRef
        .where('organizadorId', isEqualTo: userId)
        .get();

    if (plansSnapshot.docs.isEmpty) {
      return const BusinessMetricsSummary();
    }

    int totalImpresiones = 0;
    int totalConversiones = 0;
    double ingresosTotales = 0.0;
    int planesActivos = 0;
    List<PlanMetricsModel> allMetrics = [];

    for (final doc in plansSnapshot.docs) {
      final data = doc.data();

      totalImpresiones += (data['impresiones'] ?? 0) as int;
      totalConversiones += (data['conversiones'] ?? 0) as int;
      ingresosTotales += (data['ingresosTotales'] ?? 0.0).toDouble();

      if (data['estado'] == 'activo') planesActivos++;

      allMetrics.add(PlanMetricsModel.fromMap({...data, 'id': doc.id}));
    }

    // Ordenar por conversiones para obtener top planes
    allMetrics.sort((a, b) => b.conversiones.compareTo(a.conversiones));

    return BusinessMetricsSummary(
      totalPlanes: plansSnapshot.docs.length,
      planesActivos: planesActivos,
      totalImpresiones: totalImpresiones,
      totalConversiones: totalConversiones,
      ingresosTotales: ingresosTotales,
      tasaConversionPromedio: totalImpresiones > 0
          ? (totalConversiones / totalImpresiones) * 100
          : 0.0,
      topPlanes: allMetrics.take(5).toList(),
    );
  }

  /// Stream de metricas del negocio en tiempo real
  Stream<BusinessMetricsSummary> watchBusinessMetrics(String userId) {
    return _plansRef
        .where('organizadorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return const BusinessMetricsSummary();
      }

      int totalImpresiones = 0;
      int totalConversiones = 0;
      double ingresosTotales = 0.0;
      int planesActivos = 0;
      List<PlanMetricsModel> allMetrics = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        totalImpresiones += (data['impresiones'] ?? 0) as int;
        totalConversiones += (data['conversiones'] ?? 0) as int;
        ingresosTotales += (data['ingresosTotales'] ?? 0.0).toDouble();

        if (data['estado'] == 'activo') planesActivos++;

        allMetrics.add(PlanMetricsModel.fromMap({...data, 'id': doc.id}));
      }

      allMetrics.sort((a, b) => b.conversiones.compareTo(a.conversiones));

      return BusinessMetricsSummary(
        totalPlanes: snapshot.docs.length,
        planesActivos: planesActivos,
        totalImpresiones: totalImpresiones,
        totalConversiones: totalConversiones,
        ingresosTotales: ingresosTotales,
        tasaConversionPromedio: totalImpresiones > 0
            ? (totalConversiones / totalImpresiones) * 100
            : 0.0,
        topPlanes: allMetrics.take(5).toList(),
      );
    });
  }

  /// Incrementa las impresiones de un plan
  Future<void> incrementImpression(String planId) async {
    await _plansRef.doc(planId).update({
      'impresiones': FieldValue.increment(1),
    });
  }

  /// Incrementa los clics en detalles
  Future<void> incrementDetailClick(String planId) async {
    await _plansRef.doc(planId).update({
      'clicsDetalle': FieldValue.increment(1),
    });
  }

  /// Incrementa conversiones (cuando alguien se une)
  Future<void> incrementConversion(String planId) async {
    await _plansRef.doc(planId).update({
      'conversiones': FieldValue.increment(1),
    });
  }
}

/// Provider del repositorio de metricas
final metricsRepositoryProvider = Provider<MetricsRepository>((ref) {
  return MetricsRepository(FirebaseFirestore.instance);
});
