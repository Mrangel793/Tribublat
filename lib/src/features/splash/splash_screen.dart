import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/auth/provider/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        final authRepository = ref.read(authRepositoryProvider);
        final user = authRepository.currentUser;
        if (user != null) {
          context.go('/');
        } else {
          context.go('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F0F8), // Rosa muy claro arriba
              Color(0xFFF5E6F5), // Rosa lavanda
              Color(0xFFEDE4F0), // Lavanda claro abajo
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE07A5F).withAlpha(60),
                          offset: const Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Nombre de la app
                  Text(
                    'TribuLat',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                      color: const Color(0xFF2D3436),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Slogan
                  Text(
                    'Conecta. Descubre. Vive.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF636E72),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Loading indicator con gradiente
                  const _GradientCircularLoader(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Indicador de carga circular con gradiente púrpura/rosa
class _GradientCircularLoader extends StatefulWidget {
  const _GradientCircularLoader();

  @override
  State<_GradientCircularLoader> createState() => _GradientCircularLoaderState();
}

class _GradientCircularLoaderState extends State<_GradientCircularLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  const Color(0xFF9B59B6).withAlpha(0),
                  const Color(0xFF9B59B6),
                  const Color(0xFFE91E8C),
                  const Color(0xFFE91E8C).withAlpha(0),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF5E6F5), // Mismo color del fondo
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
