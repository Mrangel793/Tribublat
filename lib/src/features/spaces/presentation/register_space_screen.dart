import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/spaces/data/space_repository.dart';
import 'package:myapp/src/features/spaces/domain/business_space_model.dart';

class RegisterSpaceScreen extends ConsumerStatefulWidget {
  const RegisterSpaceScreen({super.key});

  @override
  ConsumerState<RegisterSpaceScreen> createState() =>
      _RegisterSpaceScreenState();
}

class _RegisterSpaceScreenState extends ConsumerState<RegisterSpaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dirCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _webCtrl = TextEditingController();

  SpaceCategory _categoria = SpaceCategory.otro;
  final List<DisponibilidadFranja> _disponibilidad = [];
  bool _isSubmitting = false;

  static const _dias = [
    'Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'
  ];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _dirCtrl.dispose();
    _ciudadCtrl.dispose();
    _telCtrl.dispose();
    _webCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      appBar: AppBar(
        backgroundColor: DarkFeedColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: DarkFeedColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Registrar espacio',
          style: GoogleFonts.poppins(
              color: DarkFeedColors.textPrimary,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Información básica'),
              const SizedBox(height: 12),
              _buildField(_nombreCtrl, 'Nombre del local *',
                  validator: (v) =>
                      v!.isEmpty ? 'Campo requerido' : null),
              const SizedBox(height: 12),
              _buildField(_descCtrl, 'Descripción *',
                  maxLines: 3,
                  validator: (v) =>
                      v!.isEmpty ? 'Campo requerido' : null),
              const SizedBox(height: 12),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),
              _sectionTitle('Ubicación'),
              const SizedBox(height: 12),
              _buildField(_dirCtrl, 'Dirección *',
                  validator: (v) =>
                      v!.isEmpty ? 'Campo requerido' : null),
              const SizedBox(height: 12),
              _buildField(_ciudadCtrl, 'Ciudad *',
                  validator: (v) =>
                      v!.isEmpty ? 'Campo requerido' : null),
              const SizedBox(height: 24),
              _sectionTitle('Contacto'),
              const SizedBox(height: 12),
              _buildField(_telCtrl, 'Teléfono / WhatsApp',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildField(_webCtrl, 'Sitio web o Instagram',
                  keyboardType: TextInputType.url),
              const SizedBox(height: 24),
              _sectionTitle('Disponibilidad horaria'),
              Text(
                'Agrega los días y horarios en que tu local está disponible para eventos.',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: DarkFeedColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ..._disponibilidad
                  .asMap()
                  .entries
                  .map((e) => _buildFranjaRow(e.key, e.value)),
              GestureDetector(
                onTap: _addFranja,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: DarkFeedColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: DarkFeedColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add,
                          color: DarkFeedColors.gradientViolet, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Agregar franja horaria',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: DarkFeedColors.gradientViolet,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Info de aprobación
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: DarkFeedColors.gradientOrange
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: DarkFeedColors.gradientOrange
                          .withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: DarkFeedColors.gradientOrange, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tu espacio será revisado por nuestro equipo antes de aparecer en el directorio (24-48h).',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: DarkFeedColors.gradientOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Botón registrar
              GestureDetector(
                onTap: _isSubmitting ? null : _submit,
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
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            'Registrar espacio',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: DarkFeedColors.textPrimary,
        ),
      );

  Widget _buildField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
          color: DarkFeedColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            color: DarkFeedColors.textSecondary, fontSize: 14),
        filled: true,
        fillColor: DarkFeedColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: DarkFeedColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: DarkFeedColors.borderSubtle),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: DarkFeedColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SpaceCategory>(
          value: _categoria,
          isExpanded: true,
          dropdownColor: DarkFeedColors.surface,
          style: GoogleFonts.inter(
              color: DarkFeedColors.textPrimary, fontSize: 14),
          items: SpaceCategory.values
              .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(
                        BusinessSpaceModel.labelForCategory(cat)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _categoria = v!),
        ),
      ),
    );
  }

  Widget _buildFranjaRow(int index, DisponibilidadFranja franja) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DarkFeedColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Row(
        children: [
          Text(
            franja.diaLabel,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DarkFeedColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${franja.horaInicio} – ${franja.horaFin}',
            style: GoogleFonts.inter(
                fontSize: 13,
                color: DarkFeedColors.textSecondary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                setState(() => _disponibilidad.removeAt(index)),
            child: const Icon(Icons.close,
                size: 18, color: DarkFeedColors.errorRed),
          ),
        ],
      ),
    );
  }

  void _addFranja() {
    int selectedDay = 1;
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 22, minute: 0);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: DarkFeedColors.surface,
          title: Text('Agregar horario',
              style: GoogleFonts.poppins(
                  color: DarkFeedColors.textPrimary,
                  fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: selectedDay,
                isExpanded: true,
                dropdownColor: DarkFeedColors.surface,
                style: GoogleFonts.inter(
                    color: DarkFeedColors.textPrimary),
                items: List.generate(
                  7,
                  (i) => DropdownMenuItem(
                      value: i,
                      child: Text(DisponibilidadFranja.diasNombres[i])),
                ),
                onChanged: (v) => setDlg(() => selectedDay = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final t = await showTimePicker(
                            context: context, initialTime: startTime);
                        if (t != null) setDlg(() => startTime = t);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: DarkFeedColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Desde: ${startTime.format(ctx)}',
                          style: GoogleFonts.inter(
                              color: DarkFeedColors.textPrimary,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final t = await showTimePicker(
                            context: context, initialTime: endTime);
                        if (t != null) setDlg(() => endTime = t);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: DarkFeedColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Hasta: ${endTime.format(ctx)}',
                          style: GoogleFonts.inter(
                              color: DarkFeedColors.textPrimary,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar',
                  style: GoogleFonts.inter(
                      color: DarkFeedColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final fmt = (TimeOfDay t) =>
                    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                setState(() => _disponibilidad.add(
                      DisponibilidadFranja(
                        diaSemana: selectedDay,
                        horaInicio: fmt(startTime),
                        horaFin: fmt(endTime),
                      ),
                    ));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: DarkFeedColors.gradientViolet),
              child: Text('Agregar',
                  style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final space = BusinessSpaceModel(
        id: '',
        negocioId: user.uid,
        negocioNombre: user.displayName ?? 'Negocio',
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        categoria: _categoria,
        direccion: _dirCtrl.text.trim(),
        ciudad: _ciudadCtrl.text.trim(),
        telefono: _telCtrl.text.trim(),
        web: _webCtrl.text.trim(),
        disponibilidad: _disponibilidad,
        fechaRegistro: DateTime.now(),
      );

      await ref.read(spaceRepositoryProvider).createSpace(space);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Espacio registrado! Será aprobado en 24-48h.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: DarkFeedColors.greenEmerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: DarkFeedColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
