import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/auth/data/auth_repository.dart';
import 'package:myapp/src/features/auth/provider/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authRepositoryProvider).signInWithEmail(
              email: _emailController.text,
              password: _passwordController.text,
            );
        if (!mounted) return;
        context.go('/');
      } on AuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message, style: const TextStyle(color: Colors.white)),
            backgroundColor: DarkFeedColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo o contraseña incorrectos.',
                style: TextStyle(color: Colors.white)),
            backgroundColor: DarkFeedColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (!mounted) return;
      context.go('/');
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message, style: const TextStyle(color: Colors.white)),
          backgroundColor: DarkFeedColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: DarkFeedColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      body: Stack(
        children: [
          // ── Mesh gradient inferior derecha ──
          _buildMeshGradient(),

          // ── Content ──
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildBackButton(),
                  const SizedBox(height: 32),
                  _buildTitle(),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa tus credenciales para acceder',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: DarkFeedColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildForm(),
                  const SizedBox(height: 12),
                  _buildForgotPassword(),
                  const SizedBox(height: 28),
                  _buildLoginButton(),
                  const SizedBox(height: 28),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildSocialButtons(),
                  const SizedBox(height: 32),
                  _buildFooter(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeshGradient() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _LoginAuroraPainter(),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DarkFeedColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DarkFeedColors.borderSubtle),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: DarkFeedColors.textPrimary,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenido de',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: DarkFeedColors.textPrimary,
            height: 1.2,
          ),
        ),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            'vuelta',
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email label
          Text(
            'Email',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: DarkFeedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildGlassField(
            controller: _emailController,
            focusNode: _emailFocus,
            hint: 'tu@email.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          // Password label
          Text(
            'Contrasena',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: DarkFeedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildGlassField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            hint: '••••••••••',
            icon: Icons.lock_outline,
            obscureText: _obscureText,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscureText = !_obscureText),
              child: Icon(
                _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: DarkFeedColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    final isFocused = focusNode.hasFocus;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isFocused
            ? const LinearGradient(
                colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
              )
            : null,
        border: isFocused ? null : Border.all(color: DarkFeedColors.borderSubtle),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFFF8C42).withOpacity(0.15),
                  blurRadius: 12,
                ),
              ]
            : [],
      ),
      padding: isFocused ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: DarkFeedColors.cardBackground.withOpacity(0.6),
          borderRadius: BorderRadius.circular(isFocused ? 12.5 : 14),
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: DarkFeedColors.textPrimary,
          ),
          cursorColor: const Color(0xFFFF8C42),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF6B7280),
            ),
            prefixIcon: Icon(
              icon,
              color: isFocused ? const Color(0xFFFF8C42) : DarkFeedColors.textSecondary,
              size: 20,
            ),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffixIcon,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: GoogleFonts.inter(
              fontSize: 12,
              color: DarkFeedColors.errorRed,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio';
            }
            if (controller == _emailController && !value.contains('@')) {
              return 'Ingresa un correo valido';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => context.push('/forgot-password'),
        child: Text(
          'Olvidaste tu contrasena?',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8B5CF6),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8C42).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Entrar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: DarkFeedColors.borderSubtle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'o continua con',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: DarkFeedColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: DarkFeedColors.borderSubtle),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google
        _buildSocialCircle(
          onTap: _isGoogleLoading ? null : _signInWithGoogle,
          child: _isGoogleLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C42)),
                  ),
                )
              : Text(
                  'G',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: DarkFeedColors.textPrimary,
                  ),
                ),
        ),
        const SizedBox(width: 20),
        // Apple
        _buildSocialCircle(
          onTap: () {
            // TODO: Apple sign in
          },
          child: const Icon(
            Icons.apple,
            color: DarkFeedColors.textPrimary,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialCircle({
    required VoidCallback? onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: DarkFeedColors.cardBackground,
          shape: BoxShape.circle,
          border: Border.all(color: DarkFeedColors.borderSubtle),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 14,
            color: DarkFeedColors.textSecondary,
          ),
          children: [
            const TextSpan(text: 'No tienes cuenta? '),
            TextSpan(
              text: 'Registrate',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF8C42),
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.go('/register'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mesh gradient concentrado en esquina inferior derecha
class _LoginAuroraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Orb naranja calido (inferior derecha)
    paint.shader = RadialGradient(
      center: const Alignment(0.8, 0.6),
      radius: 0.9,
      colors: [
        const Color(0xFFFF8C42).withOpacity(0.18),
        const Color(0xFFFF8C42).withOpacity(0.06),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Orb violeta (inferior derecha, desplazado)
    paint.shader = RadialGradient(
      center: const Alignment(0.5, 0.8),
      radius: 0.8,
      colors: [
        const Color(0xFF8B5CF6).withOpacity(0.14),
        const Color(0xFF8B5CF6).withOpacity(0.04),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Mezcla sutil central-inferior
    paint.shader = RadialGradient(
      center: const Alignment(0.3, 0.5),
      radius: 0.6,
      colors: [
        const Color(0xFFFF8C42).withOpacity(0.06),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
