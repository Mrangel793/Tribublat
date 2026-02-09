import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/auth/data/auth_repository.dart';
import 'package:myapp/src/features/auth/data/database_repository.dart';
import 'package:myapp/src/features/auth/provider/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  // Track focus for gradient border effect
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _emailController.text.contains('@') &&
        _passwordController.text.length >= 6;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authRepositoryProvider).signUp(
              email: _emailController.text,
              password: _passwordController.text,
              displayName: _nameController.text,
            );

        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await ref.read(databaseRepositoryProvider).createBaseUserProfile(
                uid: currentUser.uid,
                email: _emailController.text,
                nombre: _nameController.text,
              );
        }

        if (mounted) {
          context.go('/profile/setup');
        }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Back button ──
              _buildBackButton(),

              const SizedBox(height: 24),

              // ── Title ──
              _buildTitle(),

              const SizedBox(height: 36),

              // ── Form ──
              _buildForm(),

              const SizedBox(height: 28),

              // ── Continue button ──
              _buildContinueButton(),

              const SizedBox(height: 28),

              // ── Divider ──
              _buildDivider(),

              const SizedBox(height: 24),

              // ── Social buttons ──
              _buildSocialButtons(),

              const SizedBox(height: 32),

              // ── Footer ──
              _buildFooter(),

              const SizedBox(height: 32),
            ],
          ),
        ),
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
          'Crea tu',
          style: GoogleFonts.poppins(
            fontSize: 32,
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
            'cuenta',
            style: GoogleFonts.poppins(
              fontSize: 32,
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
        children: [
          _buildGlassField(
            controller: _nameController,
            focusNode: _nameFocus,
            hint: 'Nombre completo',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildGlassField(
            controller: _emailController,
            focusNode: _emailFocus,
            hint: 'Correo electronico',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildGlassField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            hint: 'Contrasena',
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
        // Gradient border when focused
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
                  spreadRadius: 0,
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
          onChanged: (_) => setState(() {}),
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
            if (controller == _passwordController && value.length < 6) {
              return 'Minimo 6 caracteres';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final isEnabled = _isFormValid && !_isLoading;

    return GestureDetector(
      onTap: isEnabled ? _submit : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.4,
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
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF8C42).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
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
                    'Continuar',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
          child: Container(
            height: 1,
            color: DarkFeedColors.borderSubtle,
          ),
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
          child: Container(
            height: 1,
            color: DarkFeedColors.borderSubtle,
          ),
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
            const TextSpan(text: 'Ya tienes cuenta? '),
            TextSpan(
              text: 'Inicia sesion',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF8C42),
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}
