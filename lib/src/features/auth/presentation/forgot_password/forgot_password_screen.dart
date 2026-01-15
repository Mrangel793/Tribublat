import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/auth/data/auth_repository.dart';
import 'package:myapp/src/features/auth/provider/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authRepositoryProvider).resetPassword(email: _emailController.text);
        if (mounted) {
          setState(() => _emailSent = true);
        }
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Botón de regreso
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 32),
                _emailSent ? _buildSuccessMessage() : _buildForm(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
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
            Icons.lock_reset,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Recuperar contrasena',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Te enviaremos un enlace para restablecerla',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF636E72),
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
            Text(
              'Correo electronico',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF2D3436),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'ejemplo@tribu.lat',
                hintStyle: const TextStyle(color: Color(0xFFB2BEC3)),
                prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF636E72)),
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
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
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
                  'Enviar enlace',
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

  Widget _buildSuccessMessage() {
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
      child: Column(
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
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Correo enviado',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Hemos enviado un enlace de recuperacion a:',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF636E72),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _emailController.text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9B59B6),
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9B59B6).withAlpha(100),
                    offset: const Offset(0, 6),
                    blurRadius: 12,
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
        ],
      ),
    );
  }
}
