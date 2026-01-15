import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myapp/src/app.dart';
import 'package:myapp/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar datos de locale para formateo de fechas
  await initializeDateFormatting('es', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
