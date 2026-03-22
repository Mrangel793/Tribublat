import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Servicio para manejo de Firebase Cloud Messaging
class NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  /// GlobalKey del Navigator para mostrar SnackBars desde el servicio
  static GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  NotificationService(this._messaging, this._firestore);

  /// Inicializa FCM: permisos, token, listeners
  Future<void> initialize(String userId) async {
    // Solicitar permiso (Android 13+ / iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obtener y guardar token actual
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveFcmToken(userId, token);
    }

    // Escuchar renovaciones de token
    _messaging.onTokenRefresh.listen((newToken) {
      _saveFcmToken(userId, newToken);
    });

    // Mensajes en foreground → mostrar SnackBar
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App abierta desde notificación (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Verificar si la app fue abierta desde una notificación (terminated)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _saveFcmToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'fcmTokenUpdatedAt': DateTime.now().toIso8601String(),
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    scaffoldMessengerKey?.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (notification.body != null) Text(notification.body!),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // El enrutamiento se puede implementar en fases futuras
    // Por ahora el usuario verá la notificación en AlertsScreen
    debugPrint('Notificación tap: ${message.data}');
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    FirebaseMessaging.instance,
    FirebaseFirestore.instance,
  );
});
