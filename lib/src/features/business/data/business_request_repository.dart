import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/business/domain/business_request_model.dart';

class BusinessRequestRepository {
  final FirebaseFirestore _firestore;

  BusinessRequestRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection('business_requests');

  /// Crea una solicitud de cuenta de negocio
  Future<void> createRequest(BusinessRequestModel request) async {
    // Verificar si ya tiene una solicitud pendiente
    final existing = await _ref
        .where('userId', isEqualTo: request.userId)
        .where('estado', isEqualTo: BusinessRequestStatus.pendiente.name)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Ya tienes una solicitud pendiente de revisión.');
    }

    final docRef = _ref.doc();
    await docRef.set({...request.toJson(), 'id': docRef.id});
  }

  /// Stream de la solicitud del usuario actual
  Stream<BusinessRequestModel?> watchMyRequest(String userId) {
    return _ref
        .where('userId', isEqualTo: userId)
        .orderBy('fechaSolicitud', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return BusinessRequestModel.fromJson(
          {...snap.docs.first.data(), 'id': snap.docs.first.id});
    });
  }

  /// Stream de todas las solicitudes para el admin
  Stream<List<BusinessRequestModel>> watchAllRequests(
      {BusinessRequestStatus? filtro}) {
    Query<Map<String, dynamic>> query =
        _ref.orderBy('fechaSolicitud', descending: true);
    if (filtro != null) {
      query = query.where('estado', isEqualTo: filtro.name);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((doc) =>
            BusinessRequestModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList());
  }

  /// Conteo de solicitudes pendientes para badge en admin
  Stream<int> watchPendingCount() {
    return _ref
        .where('estado', isEqualTo: BusinessRequestStatus.pendiente.name)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Aprobar solicitud → cambia rol del usuario a 'negocio'
  Future<void> approveRequest(
      String requestId, String userId, String notaAdmin) async {
    await _firestore.runTransaction((transaction) async {
      // Actualizar estado de la solicitud
      transaction.update(_ref.doc(requestId), {
        'estado': BusinessRequestStatus.aprobada.name,
        'fechaResolucion': DateTime.now().toIso8601String(),
        'notaAdmin': notaAdmin,
      });

      // Cambiar rol del usuario a 'negocio'
      transaction.update(_firestore.collection('users').doc(userId), {
        'rol': 'negocio',
      });

      // Notificación para el usuario
      final notifRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc();
      transaction.set(notifRef, {
        'id': notifRef.id,
        'userId': userId,
        'tipo': 'asistenciaConfirmada',
        'titulo': '¡Solicitud de negocio aprobada!',
        'cuerpo':
            'Tu cuenta de negocio fue activada. Ya puedes registrar tu local en el directorio.',
        'fechaCreacion': DateTime.now().toIso8601String(),
        'leida': false,
      });
    });
  }

  /// Rechazar solicitud
  Future<void> rejectRequest(
      String requestId, String userId, String notaAdmin) async {
    await _ref.doc(requestId).update({
      'estado': BusinessRequestStatus.rechazada.name,
      'fechaResolucion': DateTime.now().toIso8601String(),
      'notaAdmin': notaAdmin,
    });

    // Notificación para el usuario
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'userId': userId,
      'tipo': 'planCancelado',
      'titulo': 'Solicitud de negocio no aprobada',
      'cuerpo': notaAdmin.isNotEmpty
          ? 'Motivo: $notaAdmin'
          : 'Tu solicitud fue revisada y no fue aprobada en este momento.',
      'fechaCreacion': DateTime.now().toIso8601String(),
      'leida': false,
    });
  }
}

final businessRequestRepositoryProvider =
    Provider<BusinessRequestRepository>((ref) {
  return BusinessRequestRepository(FirebaseFirestore.instance);
});

final myBusinessRequestProvider =
    StreamProvider.family<BusinessRequestModel?, String>((ref, userId) {
  return ref
      .watch(businessRequestRepositoryProvider)
      .watchMyRequest(userId);
});

final allBusinessRequestsProvider =
    StreamProvider.family<List<BusinessRequestModel>,
        BusinessRequestStatus?>((ref, filtro) {
  return ref
      .watch(businessRequestRepositoryProvider)
      .watchAllRequests(filtro: filtro);
});

final pendingBusinessCountProvider = StreamProvider<int>((ref) {
  return ref.watch(businessRequestRepositoryProvider).watchPendingCount();
});
