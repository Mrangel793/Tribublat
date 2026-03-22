import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/auth/presentation/forgot_password/forgot_password_screen.dart';
import 'package:myapp/src/features/auth/presentation/login/login_screen.dart';
import 'package:myapp/src/features/auth/presentation/welcome/welcome_screen.dart';
import 'package:myapp/src/features/auth/presentation/register/register_screen.dart';
import 'package:myapp/src/features/main/main_screen.dart';
import 'package:myapp/src/features/plans/presentation/create/screens/create_plan_screen.dart';
import 'package:myapp/src/features/plans/presentation/detail/screens/plan_detail_screen.dart';
import 'package:myapp/src/features/profile/presentation/edit/edit_profile_screen.dart';
import 'package:myapp/src/features/profile/presentation/public/public_profile_screen.dart';
import 'package:myapp/src/features/profile/presentation/setup/screens/profile_setup_screen.dart';
import 'package:myapp/src/features/splash/splash_screen.dart';
// Importaciones para modulos de roles
import 'package:myapp/src/features/business/presentation/metrics/business_metrics_screen.dart';
import 'package:myapp/src/features/admin/presentation/admin_panel_screen.dart';
import 'package:myapp/src/features/admin/presentation/user_management_screen.dart';
import 'package:myapp/src/features/admin/presentation/reports_screen.dart';
// Importaciones para exploracion
import 'package:myapp/src/features/explore/category_plans_screen.dart';
import 'package:myapp/src/features/chat/presentation/chat_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/create-plan',
      builder: (context, state) => const CreatePlanScreen(),
    ),
    GoRoute(
      path: '/plan/:id',
      builder: (context, state) {
        final planId = state.pathParameters['id']!;
        return PlanDetailScreen(planId: planId);
      },
    ),
    GoRoute(
      path: '/plan/:id/chat',
      builder: (context, state) {
        final planId = state.pathParameters['id']!;
        return ChatScreen(planId: planId);
      },
    ),
    // === RUTAS DE EXPLORACION ===
    GoRoute(
      path: '/explore/category/:categoryId',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        return CategoryPlansScreen(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: '/profile/setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return PublicProfileScreen(userId: userId);
      },
    ),

    // === RUTAS DE NEGOCIO (protegidas por rol) ===
    GoRoute(
      path: '/business/metrics',
      builder: (context, state) => const BusinessMetricsScreen(),
    ),
    GoRoute(
      path: '/business/metrics/:planId',
      builder: (context, state) {
        final planId = state.pathParameters['planId']!;
        return _PlanMetricsPlaceholder(planId: planId);
      },
    ),

    // === RUTAS DE ADMIN (protegidas por rol) ===
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminPanelScreen(),
    ),
    GoRoute(
      path: '/admin/users',
      builder: (context, state) => const UserManagementScreen(),
    ),
    GoRoute(
      path: '/admin/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
  ],
);

// Placeholder para metricas de plan individual (en desarrollo)
class _PlanMetricsPlaceholder extends StatelessWidget {
  final String planId;
  const _PlanMetricsPlaceholder({required this.planId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metricas del Plan'),
        backgroundColor: const Color(0xFFFFB347),
      ),
      body: Center(
        child: Text('Metricas del plan: $planId\n(En desarrollo)'),
      ),
    );
  }
}
