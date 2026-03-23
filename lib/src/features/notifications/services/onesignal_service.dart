import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:myapp/src/features/notifications/services/onesignal_config.dart';

class OneSignalService {
  static const String _appId = OneSignalConfig.appId;
  static const String _restApiKey = OneSignalConfig.restApiKey;

  static bool get isConfigured =>
      _appId != 'TU_ONESIGNAL_APP_ID' && _restApiKey != 'TU_ONESIGNAL_REST_API_KEY';

  /// Inicializa OneSignal y asocia el usuario con su Firebase UID
  Future<void> initialize(String userId) async {
    if (!isConfigured) {
      debugPrint('OneSignal: No configurado. Reemplaza App ID y REST API Key.');
      return;
    }

    // Inicializar OneSignal
    OneSignal.initialize(_appId);

    // Solicitar permiso de notificaciones
    await OneSignal.Notifications.requestPermission(true);

    // Asociar el dispositivo con el Firebase UID del usuario
    // Esto permite enviar notificaciones a un usuario específico por su ID
    await OneSignal.login(userId);

    // Handler cuando llega una notificación y la app está en foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      // Mostrar la notificación normalmente
      event.notification.display();
    });

    // Handler cuando el usuario toca una notificación
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      debugPrint('Notificación tocada: $data');
      // El enrutamiento se puede implementar aquí en fases futuras
    });

    debugPrint('OneSignal inicializado para usuario: $userId');
  }

  /// Envía una notificación push a un usuario específico
  /// [targetUserId] = Firebase UID del destinatario
  static Future<void> sendPushToUser({
    required String targetUserId,
    required String titulo,
    required String cuerpo,
    String? planId,
  }) async {
    if (!isConfigured) return;

    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode({
          'app_id': _appId,
          // Enviar al External User ID (Firebase UID)
          'include_aliases': {
            'external_id': [targetUserId],
          },
          'target_channel': 'push',
          'headings': {'es': titulo, 'en': titulo},
          'contents': {'es': cuerpo, 'en': cuerpo},
          // Datos extra para cuando el usuario toque la notificación
          if (planId != null) 'data': {'planId': planId},
          // Icono y sonido (opcional)
          'android_accent_color': 'FF9B59B6',
          'small_icon': 'ic_stat_onesignal_default',
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Push enviado a $targetUserId: $titulo');
      } else {
        debugPrint('Error OneSignal ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error enviando push: $e');
    }
  }

  /// Envía una notificación push a múltiples usuarios
  static Future<void> sendPushToUsers({
    required List<String> targetUserIds,
    required String titulo,
    required String cuerpo,
    String? planId,
  }) async {
    if (!isConfigured || targetUserIds.isEmpty) return;

    try {
      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode({
          'app_id': _appId,
          'include_aliases': {
            'external_id': targetUserIds,
          },
          'target_channel': 'push',
          'headings': {'es': titulo, 'en': titulo},
          'contents': {'es': cuerpo, 'en': cuerpo},
          if (planId != null) 'data': {'planId': planId},
          'android_accent_color': 'FF9B59B6',
        }),
      );
    } catch (e) {
      debugPrint('Error enviando push masivo: $e');
    }
  }
}

final oneSignalServiceProvider = Provider<OneSignalService>((ref) {
  return OneSignalService();
});
