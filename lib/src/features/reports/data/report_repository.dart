import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/notifications/data/notification_repository.dart';
import 'package:myapp/src/features/notifications/domain/notification_model.dart';
import 'package:myapp/src/features/reports/domain/report_model.dart';

class ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _firestore.collection('reports');

  /// Crea un reporte de usuario
  Future<void> createReport(ReportModel report) async {
    final docRef = _reportsRef.doc();
    await docRef.set({...report.toJson(), 'id': docRef.id});
  }

  /// Stream de todos los reportes (para admin), ordenados por fecha
  Stream<List<ReportModel>> watchAllReports({ReportStatus? filtroEstado}) {
    Query<Map<String, dynamic>> query =
        _reportsRef.orderBy('fechaCreacion', descending: true).limit(100);

    if (filtroEstado != null) {
      query = query.where('estado', isEqualTo: filtroEstado.name);
    }

    return query.snapshots().map((snap) => snap.docs
        .map((doc) => ReportModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList());
  }

  /// Conteo de reportes nuevos (para badge en admin)
  Stream<int> watchNewReportsCount() {
    return _reportsRef
        .where('estado', isEqualTo: ReportStatus.nuevo.name)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Resuelve un reporte con una acción y notifica al reportero
  Future<void> resolveReport({
    required String reportId,
    required String reporterId,
    required ReportAction accion,
    required String notaAdmin,
    required NotificationRepository notificationRepo,
  }) async {
    await _reportsRef.doc(reportId).update({
      'estado': ReportStatus.resuelto.name,
      'accionTomada': accion.name,
      'notaAdmin': notaAdmin,
      'fechaResolucion': DateTime.now().toIso8601String(),
    });

    // Notificar al reportero que su reporte fue revisado
    final notif = NotificationModel(
      id: '',
      userId: reporterId,
      tipo: NotificationType.planCambiado, // reutilizamos para "actualización"
      titulo: 'Tu reporte fue revisado',
      cuerpo: 'Hemos revisado tu reporte. '
          'Acción tomada: ${ReportModel.labelForAction(accion)}.',
      fechaCreacion: DateTime.now(),
      leida: false,
    );
    await notificationRepo.createNotification(notif);
  }

  /// Cambia el estado a "revisando"
  Future<void> markAsReviewing(String reportId) async {
    await _reportsRef.doc(reportId).update({
      'estado': ReportStatus.revisando.name,
    });
  }
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(FirebaseFirestore.instance);
});

final allReportsProvider = StreamProvider.family<List<ReportModel>,
    ReportStatus?>((ref, filtro) {
  return ref.watch(reportRepositoryProvider).watchAllReports(filtroEstado: filtro);
});

final newReportsCountProvider = StreamProvider<int>((ref) {
  return ref.watch(reportRepositoryProvider).watchNewReportsCount();
});
