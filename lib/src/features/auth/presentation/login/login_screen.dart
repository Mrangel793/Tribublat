import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/auth/data/auth_repository.dart';
import 'package:myapp/src/features/auth/presentation/register/register_screen.dart';
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
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        _showSuccessDialog();
      } on AuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
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
      _showSuccessDialog();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4ECDC4),
                  size: 45,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Inicio exitoso',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bienvenido a TribuLat',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF636E72),
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  context.go('/');
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Continuar',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FA), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              _buildHeader(),
              _buildForm(),
              const SizedBox(height: 32),
              _buildFooter(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 24),
      child: Column(
        children: [
          // Icono circular púrpura
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF9B59B6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9B59B6).withAlpha(77),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Bienvenido de vuelta!',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicia sesion para continuar',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF636E72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(38),
            spreadRadius: 5,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextFormField(
              controller: _emailController,
              label: 'Correo electronico',
              hint: 'ejemplo@tribu.lat',
              icon: Icons.mail_outline,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _passwordController,
              label: 'Contrasena',
              hint: '••••••••••',
              icon: Icons.lock_outline,
              obscureText: _obscureText,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF636E72),
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
            ),
            const SizedBox(height: 16),
            _buildRememberMeAndForgotPassword(),
            const SizedBox(height: 24),
            _buildLoginButton(),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 16),
            _buildSocialButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D3436), fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB2BEC3)),
            prefixIcon: Icon(icon, color: const Color(0xFF636E72)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9B59B6), width: 2),
            ),
          ),
          validator: (value) => (value == null || value.isEmpty) ? 'Este campo es obligatorio' : null,
        ),
      ],
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) => setState(() => _rememberMe = value!),
                activeColor: const Color(0xFF9B59B6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(color: Color(0xFFB2BEC3)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Mantener sesion',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF636E72),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => context.push('/forgot-password'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Olvidaste?',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF9B59B6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return InkWell(
      onTap: _isLoading ? null : _submit,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: _isLoading
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF9B59B6).withAlpha(100),
                    offset: const Offset(0, 6),
                    blurRadius: 12,
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
                  'Iniciar Sesion',
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
        const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('O continua con', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF636E72))),
        ),
        const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Center(
      child: OutlinedButton(
        onPressed: _isGoogleLoading ? null : _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(
            color: _isGoogleLoading ? Colors.grey.shade300 : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        ),
        child: _isGoogleLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    'https://www.google.com/favicon.ico',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.g_mobiledata,
                      size: 28,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continuar con Google',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF636E72)),
        children: [
          const TextSpan(text: 'No tienes cuenta?  '),
          TextSpan(
            text: 'Registrate',
            style: GoogleFonts.poppins(
              color: const Color(0xFF9B59B6),
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  ),
          ),
        ],
      ),
    );
  }
}
