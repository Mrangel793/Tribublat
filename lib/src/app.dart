import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/config/router/app_router.dart';
import 'package:myapp/src/features/auth/provider/auth_provider.dart';
import 'package:myapp/src/features/notifications/services/notification_service.dart';
import 'package:myapp/src/features/notifications/services/onesignal_service.dart';

final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.scaffoldMessengerKey = _scaffoldMessengerKey;

    // Inicializar servicios si el usuario ya está autenticado al arrancar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateChangesProvider).valueOrNull;
      if (user != null) {
        ref.read(notificationServiceProvider).initialize(user.uid);
        ref.read(oneSignalServiceProvider).initialize(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar cuando cambia el estado de auth (login/logout)
    ref.listen(authStateChangesProvider, (previous, next) {
      final user = next.valueOrNull;
      final prevUser = previous?.valueOrNull;
      // Solo inicializar cuando hay un cambio real de usuario
      if (user != null && user.uid != prevUser?.uid) {
        ref.read(notificationServiceProvider).initialize(user.uid);
        ref.read(oneSignalServiceProvider).initialize(user.uid);
      }
    });

    return MaterialApp.router(
      title: 'TribuLat',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B59B6)),
      ),
      // Localizaciones para español
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''),
        Locale('en', ''),
      ],
      locale: const Locale('es'),
      routerConfig: appRouter,
    );
  }
}
