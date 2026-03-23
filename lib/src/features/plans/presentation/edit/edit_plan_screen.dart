import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/notifications/services/onesignal_service.dart';
import 'package:myapp/src/features/plans/data/plan_repository.dart';

class EditPlanScreen extends ConsumerStatefulWidget {
  final String planId;
  const EditPlanScreen({super.key, required this.planId});

  @override
  ConsumerState<EditPlanScreen> createState() => _EditPlanScreenState();
}

class _EditPlanScreenState extends ConsumerState<EditPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _cuposCtrl = TextEditingController();

  DateTime? _fechaHora;
  bool _isLoading = true;
  bool _isSaving = false;
  List<String> _participantesIds = [];

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _ubicacionCtrl.dispose();
    _cuposCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPlan() async {
    final doc = await FirebaseFirestore.instance
        .collection('plans')
        .doc(widget.planId)
        .get();

    if (!doc.exists || !mounted) return;

    final data = doc.data()!;
    setState(() {
      _tituloCtrl.text = data['titulo'] as String? ?? '';
      _descCtrl.text = data['descripcion'] as String? ?? '';
      _ubicacionCtrl.text = data['ubicacionNombre'] as String? ?? '';
      _cuposCtrl.text = (data['capacidadMaxima'] as int? ?? 5).toString();
      _fechaHora = data['fechaHora'] != null
          ? DateTime.parse(data['fechaHora'] as String)
          : null;
      _participantesIds =
          List<String>.from(data['participantesIds'] ?? []);
      _isLoading = false;
    });
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
          'Editar plan',
          style: GoogleFonts.poppins(
            color: DarkFeedColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: DarkFeedColors.gradientOrange))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Título *'),
                    _buildField(
                      _tituloCtrl,
                      'Nombre del plan',
                      validator: (v) =>
                          v!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('Descripción *'),
                    _buildField(
                      _descCtrl,
                      'Describe tu plan',
                      maxLines: 4,
                      validator: (v) =>
                          v!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('Ubicación'),
                    _buildField(_ubicacionCtrl, 'Nombre del lugar'),
                    const SizedBox(height: 16),
                    _sectionLabel('Cupos máximos *'),
                    _buildField(
                      _cuposCtrl,
                      'Número de personas',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1) return 'Mínimo 1 cupo';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('Fecha y hora *'),
                    GestureDetector(
                      onTap: _pickDateTime,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: DarkFeedColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: DarkFeedColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                color: DarkFeedColors.textSecondary,
                                size: 18),
                            const SizedBox(width: 10),
                            Text(
                              _fechaHora != null
                                  ? DateFormat('dd/MM/yyyy – HH:mm')
                                      .format(_fechaHora!)
                                  : 'Seleccionar fecha y hora',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: _fechaHora != null
                                    ? DarkFeedColors.textPrimary
                                    : DarkFeedColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Info de notificación
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DarkFeedColors.gradientViolet
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: DarkFeedColors.gradientViolet
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_outlined,
                              color: DarkFeedColors.gradientViolet,
                              size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Los participantes recibirán una notificación con los cambios.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: DarkFeedColors.gradientViolet,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _isSaving ? null : _save,
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: DarkFeedColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5),
                                )
                              : Text(
                                  'Guardar cambios',
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

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: DarkFeedColors.textSecondary,
          ),
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

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaHora ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark(),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _fechaHora != null
          ? TimeOfDay.fromDateTime(_fechaHora!)
          : const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.dark(),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      _fechaHora =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaHora == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecciona la fecha y hora del plan'),
        backgroundColor: DarkFeedColors.errorRed,
      ));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updates = {
        'titulo': _tituloCtrl.text.trim(),
        'descripcion': _descCtrl.text.trim(),
        'ubicacionNombre': _ubicacionCtrl.text.trim(),
        'capacidadMaxima': int.parse(_cuposCtrl.text),
        'fechaHora': _fechaHora!.toIso8601String(),
      };

      await ref
          .read(planRepositoryProvider)
          .updatePlan(widget.planId, updates);

      // Notificar a los participantes del cambio
      if (_participantesIds.isNotEmpty) {
        final titulo = _tituloCtrl.text.trim();

        // Notificación in-app en Firestore para cada participante
        final batch = FirebaseFirestore.instance.batch();
        for (final userId in _participantesIds) {
          final notifRef = FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc();
          batch.set(notifRef, {
            'id': notifRef.id,
            'userId': userId,
            'tipo': 'planCambiado',
            'titulo': 'Plan actualizado',
            'cuerpo': '"$titulo" ha sido modificado. Revisa los nuevos detalles.',
            'planId': widget.planId,
            'planTitulo': titulo,
            'fechaCreacion': DateTime.now().toIso8601String(),
            'leida': false,
          });
        }
        await batch.commit();

        // Push por OneSignal
        await OneSignalService.sendPushToUsers(
          targetUserIds: _participantesIds,
          titulo: 'Plan actualizado',
          cuerpo:
              '"${_tituloCtrl.text.trim()}" ha sido modificado. Revisa los nuevos detalles.',
          planId: widget.planId,
        );
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Plan actualizado',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: DarkFeedColors.greenEmerald,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: DarkFeedColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
