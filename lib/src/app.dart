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
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar NotificationService cuando el usuario se autentica
    ref.listen(authStateChangesProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null) {
        // Inicializar Firebase Messaging
        ref.read(notificationServiceProvider).initialize(user.uid);
        // Inicializar OneSignal
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
