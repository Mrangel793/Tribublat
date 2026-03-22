import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/notifications/domain/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> _notificationsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  /// Crea una notificación en Firestore para un usuario
  Future<void> createNotification(NotificationModel notification) async {
    final docRef = _notificationsRef(notification.userId).doc();
    await docRef.set({...notification.toJson(), 'id': docRef.id});
  }

  /// Stream de notificaciones del usuario, ordenadas por fecha desc
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _notificationsRef(userId)
        .orderBy('fechaCreacion', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                NotificationModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Stream del conteo de notificaciones no leídas
  Stream<int> watchUnreadCount(String userId) {
    return _notificationsRef(userId)
        .where('leida', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(String userId, String notificationId) async {
    await _notificationsRef(userId).doc(notificationId).update({'leida': true});
  }

  /// Marca todas las notificaciones del usuario como leídas
  Future<void> markAllAsRead(String userId) async {
    final unread = await _notificationsRef(userId)
        .where('leida', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'leida': true});
    }
    await batch.commit();
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(FirebaseFirestore.instance);
});

/// Stream de notificaciones del usuario actual
final notificationsStreamProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).watchNotifications(userId);
});

/// Stream del conteo de no leídas
final unreadCountProvider = StreamProvider.family<int, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).watchUnreadCount(userId);
});
