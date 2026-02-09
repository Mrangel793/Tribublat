import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';

/// Pantalla de bienvenida premium dark mode
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      body: Stack(
        children: [
          // ── Mesh gradient aurora background ──
          _buildAuroraBackground(),

          // ── Content ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // ── Logo with breathing glow ──
                  _buildLogo(),

                  const SizedBox(height: 32),

                  // ── Tagline ──
                  _buildTagline(),

                  const Spacer(flex: 3),

                  // ── Buttons ──
                  _buildCreateAccountButton(),
                  const SizedBox(height: 14),
                  _buildLoginButton(),

                  const SizedBox(height: 24),

                  // ── Terms text ──
                  _buildTermsText(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Aurora boreal mesh gradient en la parte superior
  Widget _buildAuroraBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _AuroraPainter(),
      ),
    );
  }

  /// Logo con breathing glow animado
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8C42)
                    .withOpacity(0.3 * _glowAnimation.value),
                blurRadius: 40 * _glowAnimation.value,
                spreadRadius: 5 * _glowAnimation.value,
              ),
              BoxShadow(
                color: const Color(0xFF8B5CF6)
                    .withOpacity(0.2 * _glowAnimation.value),
                blurRadius: 60 * _glowAnimation.value,
                spreadRadius: 10 * _glowAnimation.value,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  /// Tagline "Conecta. Descubre. Vive."
  Widget _buildTagline() {
    return Column(
      children: [
        Text(
          'Conecta.',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: DarkFeedColors.textPrimary,
            letterSpacing: 1.2,
            height: 1.4,
          ),
        ),
        Text(
          'Descubre.',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: DarkFeedColors.textPrimary,
            letterSpacing: 1.2,
            height: 1.4,
          ),
        ),
        // "Vive." con gradiente
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            'Vive.',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.2,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Boton "Crear cuenta" con gradiente solido
  Widget _buildCreateAccountButton() {
    return GestureDetector(
      onTap: () => context.push('/register'),
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8C42).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Crear cuenta',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Boton "Ya tengo cuenta" outline/ghost con borde gradiente
  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: () => context.push('/login'),
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        padding: const EdgeInsets.all(1.5), // grosor del borde gradiente
        child: Container(
          decoration: BoxDecoration(
            color: DarkFeedColors.background,
            borderRadius: BorderRadius.circular(14.5),
          ),
          child: Center(
            child: Text(
              'Ya tengo cuenta',
              style: GoogleFonts.poppins(
                color: DarkFeedColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Texto de terminos y politica de privacidad
  Widget _buildTermsText() {
    return Text(
      'Al continuar, aceptas nuestros Terminos y Politica de Privacidad',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 12,
        color: const Color(0xFFA1A1AA),
        height: 1.5,
      ),
    );
  }
}

/// Custom painter para el efecto de aurora boreal
class _AuroraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Orb naranja (izquierda superior)
    paint.shader = RadialGradient(
      center: const Alignment(-0.5, -0.7),
      radius: 0.8,
      colors: [
        const Color(0xFFFF8C42).withOpacity(0.25),
        const Color(0xFFFF8C42).withOpacity(0.08),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Orb violeta (derecha superior)
    paint.shader = RadialGradient(
      center: const Alignment(0.6, -0.5),
      radius: 0.9,
      colors: [
        const Color(0xFF8B5CF6).withOpacity(0.2),
        const Color(0xFF8B5CF6).withOpacity(0.06),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Orb mezcla central (sutil)
    paint.shader = RadialGradient(
      center: const Alignment(0.0, -0.3),
      radius: 0.6,
      colors: [
        const Color(0xFFFF8C42).withOpacity(0.1),
        const Color(0xFF8B5CF6).withOpacity(0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
