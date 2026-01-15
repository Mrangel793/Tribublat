import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/auth/presentation/forgot_password/forgot_password_screen.dart';
import 'package:myapp/src/features/auth/presentation/login/login_screen.dart';
import 'package:myapp/src/features/plans/presentation/create/screens/create_plan_screen.dart';
import 'package:myapp/src/features/plans/presentation/feed/screens/feed_screen.dart';
import 'package:myapp/src/features/splash/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const FeedScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/create-plan',
      builder: (context, state) => const CreatePlanScreen(),
    ),
  ],
);
