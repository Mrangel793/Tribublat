import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/business/data/business_request_repository.dart';
import 'package:myapp/src/features/business/domain/business_request_model.dart';
import 'package:myapp/src/features/notifications/services/onesignal_service.dart';

class RequestBusinessScreen extends ConsumerStatefulWidget {
  const RequestBusinessScreen({super.key});

  @override
  ConsumerState<RequestBusinessScreen> createState() =>
      _RequestBusinessScreenState();
}

class _RequestBusinessScreenState
    extends ConsumerState<RequestBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  BusinessType _tipoNegocio = BusinessType.otro;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _nitCtrl.dispose();
    _telCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    // Si ya tiene solicitud, mostrar su estado
    final requestAsync = ref.watch(myBusinessRequestProvider(user.uid));

    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      appBar: AppBar(
        backgroundColor: DarkFeedColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: DarkFeedColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Cuenta de negocio',
            style: GoogleFonts.poppins(
                color: DarkFeedColors.textPrimary,
                fontWeight: FontWeight.w600)),
      ),
      body: requestAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(
                color: DarkFeedColors.gradientOrange)),
        error: (_, __) => _buildForm(user),
        data: (request) {
          if (request != null) return _buildStatus(request);
          return _buildForm(user);
        },
      ),
    );
  }

  /// Si ya envió solicitud → mostrar estado actual
  Widget _buildStatus(BusinessRequestModel request) {
    final isPending = request.estado == BusinessRequestStatus.pendiente;
    final isApproved = request.estado == BusinessRequestStatus.aprobada;

    final color = isApproved
        ? DarkFeedColors.greenEmerald
        : isPending
            ? DarkFeedColors.gradientOrange
            : DarkFeedColors.errorRed;

    final icon = isApproved
        ? Icons.check_circle_outline
        : isPending
            ? Icons.hourglass_empty
            : Icons.cancel_outlined;

    final title = isApproved
        ? '¡Solicitud aprobada!'
        : isPending
            ? 'Solicitud en revisión'
            : 'Solicitud no aprobada';

    final subtitle = isApproved
        ? 'Tu cuenta de negocio está activa. Ya puedes registrar tu local en el Directorio de Espacios.'
        : isPending
            ? 'Nuestro equipo revisará tu solicitud en 24-48 horas y te notificaremos.'
            : (request.notaAdmin?.isNotEmpty == true
                ? 'Motivo: ${request.notaAdmin}'
                : 'Tu solicitud no fue aprobada en este momento.');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 24),
          Text(title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: DarkFeedColors.textPrimary,
              ),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: DarkFeedColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          // Info del negocio solicitado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DarkFeedColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: DarkFeedColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Empresa', request.nombreEmpresa),
                _infoRow('NIT / RUT', request.nit),
                _infoRow('Tipo',
                    BusinessRequestModel.labelForType(request.tipoNegocio)),
                _infoRow('Teléfono', request.telefono),
              ],
            ),
          ),
          if (request.estado == BusinessRequestStatus.rechazada) ...[
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                // Permitir reenviar solicitud
                ref
                    .read(businessRequestRepositoryProvider)
                    .createRequest; // reset state
                setState(() {});
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: DarkFeedColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text('Enviar nueva solicitud',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text('$label: ',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: DarkFeedColors.textSecondary)),
            Expanded(
              child: Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DarkFeedColors.textPrimary)),
            ),
          ],
        ),
      );

  Widget _buildForm(User user) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner explicativo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: DarkFeedColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.store_rounded,
                      color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cuenta de negocio',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text(
                            'Registra tu local, recibe visibilidad y gestiona eventos.',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionLabel('Nombre de la empresa *'),
            _buildField(_nombreCtrl, 'Ej: Café Central',
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 14),
            _sectionLabel('NIT o RUT *'),
            _buildField(_nitCtrl, 'Ej: 900123456-7',
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 14),
            _sectionLabel('Tipo de negocio *'),
            _buildTypeDropdown(),
            const SizedBox(height: 14),
            _sectionLabel('Teléfono / WhatsApp *'),
            _buildField(_telCtrl, 'Ej: 3001234567',
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 14),
            _sectionLabel('Descripción del negocio *'),
            _buildField(_descCtrl,
                'Cuéntanos qué es tu negocio y por qué quieres unirte...',
                maxLines: 4,
                validator: (v) =>
                    v!.length < 20 ? 'Mínimo 20 caracteres' : null),
            const SizedBox(height: 8),
            Text(
              '⏱️ Revisamos solicitudes en 24-48 horas y te notificamos por la app.',
              style: GoogleFonts.inter(
                  fontSize: 12, color: DarkFeedColors.textSecondary),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _isSubmitting ? null : () => _submit(user),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: DarkFeedColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text('Enviar solicitud',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DarkFeedColors.textSecondary)),
      );

  Widget _buildField(TextEditingController ctrl, String hint,
      {int maxLines = 1,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style:
          GoogleFonts.inter(color: DarkFeedColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            color: DarkFeedColors.textSecondary, fontSize: 14),
        filled: true,
        fillColor: DarkFeedColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DarkFeedColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DarkFeedColors.borderSubtle),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: DarkFeedColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BusinessType>(
          value: _tipoNegocio,
          isExpanded: true,
          dropdownColor: DarkFeedColors.surface,
          style: GoogleFonts.inter(
              color: DarkFeedColors.textPrimary, fontSize: 14),
          items: BusinessType.values
              .map((t) => DropdownMenuItem(
                    value: t,
                    child:
                        Text(BusinessRequestModel.labelForType(t)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _tipoNegocio = v!),
        ),
      ),
    );
  }

  Future<void> _submit(User user) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final request = BusinessRequestModel(
        id: '',
        userId: user.uid,
        userName: user.displayName ?? 'Usuario',
        userEmail: user.email ?? '',
        nombreEmpresa: _nombreCtrl.text.trim(),
        nit: _nitCtrl.text.trim(),
        tipoNegocio: _tipoNegocio,
        telefono: _telCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        estado: BusinessRequestStatus.pendiente,
        fechaSolicitud: DateTime.now(),
      );

      await ref
          .read(businessRequestRepositoryProvider)
          .createRequest(request);

      // Notificar a admins por OneSignal (si está configurado)
      await OneSignalService.sendPushToUser(
        targetUserId: user.uid,
        titulo: 'Solicitud recibida',
        cuerpo:
            'Recibimos tu solicitud de cuenta de negocio. Te notificaremos en 24-48h.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('¡Solicitud enviada! Te avisaremos pronto.',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: DarkFeedColors.greenEmerald,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(),
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: DarkFeedColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
