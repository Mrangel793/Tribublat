import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/auth/data/auth_repository.dart';
import 'package:myapp/src/features/auth/provider/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(authRepositoryProvider)
            .resetPassword(email: _emailController.text);
        if (mounted) {
          setState(() => _emailSent = true);
        }
      } on AuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(e.message, style: const TextStyle(color: Colors.white)),
            backgroundColor: DarkFeedColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
              _buildBackButton(),
              const SizedBox(height: 48),
              if (_emailSent) _buildSuccessState() else _buildFormState(),
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

  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Mail icon with gradient ──
        Center(child: _buildMailIcon()),
        const SizedBox(height: 32),

        // ── Title ──
        Center(
          child: Text(
            'Recupera tu acceso',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: DarkFeedColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Subtitle ──
        Center(
          child: Text(
            'Te enviaremos un enlace para\nrestablecer tu contrasena',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: DarkFeedColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 40),

        // ── Email label ──
        Text(
          'Correo electronico',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: DarkFeedColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        // ── Email field ──
        _buildGlassField(),

        const SizedBox(height: 32),

        // ── Submit button ──
        _buildSubmitButton(),

        const SizedBox(height: 24),

        // ── Help text ──
        Center(
          child: Text(
            'No tienes acceso al correo?',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: DarkFeedColors.textSecondary,
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMailIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF8C42).withOpacity(0.15),
            const Color(0xFF8B5CF6).withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: DarkFeedColors.borderSubtle,
        ),
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: const Icon(
          Icons.mail_outline,
          size: 38,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGlassField() {
    final isFocused = _emailFocus.hasFocus;

    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isFocused
              ? const LinearGradient(
                  colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
                )
              : null,
          border: isFocused
              ? null
              : Border.all(color: DarkFeedColors.borderSubtle),
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
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: DarkFeedColors.textPrimary,
            ),
            cursorColor: const Color(0xFFFF8C42),
            decoration: InputDecoration(
              hintText: 'ejemplo@tribulat.com',
              hintStyle: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF6B7280),
              ),
              prefixIcon: Icon(
                Icons.mail_outline,
                color: isFocused
                    ? const Color(0xFFFF8C42)
                    : DarkFeedColors.textSecondary,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              errorStyle: GoogleFonts.inter(
                fontSize: 12,
                color: DarkFeedColors.errorRed,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
              }
              if (!value.contains('@')) {
                return 'Ingresa un correo valido';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enviar enlace',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
      ),
    );
  }

  // ── Success state after email sent ──
  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DarkFeedColors.greenEmerald.withOpacity(0.15),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: DarkFeedColors.greenEmerald,
            size: 44,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Correo enviado',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: DarkFeedColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Hemos enviado un enlace de\nrecuperacion a:',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: DarkFeedColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            _emailController.text,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Back to login button
        GestureDetector(
          onTap: () => Navigator.pop(context),
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
              child: Text(
                'Volver al login',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Resend option
        GestureDetector(
          onTap: () => setState(() => _emailSent = false),
          child: Text(
            'Enviar de nuevo',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8B5CF6),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
