import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myapp/src/app.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/src/features/notifications/services/notification_service.dart';

/// Handler para mensajes FCM cuando la app está en background/terminated.
/// Debe ser una función de nivel superior (no método de clase).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar datos de locale para formateo de fechas
  await initializeDateFormatting('es', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Maximizar caché de Firestore → segunda carga es instantánea
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Registrar handler de mensajes en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Deshabilitar App Check y reCAPTCHA en modo desarrollo
  await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: true,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
