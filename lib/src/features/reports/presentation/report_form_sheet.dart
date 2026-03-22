import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/reports/data/report_repository.dart';
import 'package:myapp/src/features/reports/domain/report_model.dart';

class ReportFormSheet extends ConsumerStatefulWidget {
  final String reportedUserId;
  final String reportedUserName;

  const ReportFormSheet({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
  });

  @override
  ConsumerState<ReportFormSheet> createState() => _ReportFormSheetState();
}

class _ReportFormSheetState extends ConsumerState<ReportFormSheet> {
  ReportType? _selectedType;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: DarkFeedColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: DarkFeedColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: DarkFeedColors.errorRed),
              const SizedBox(width: 8),
              Text(
                'Reportar a ${widget.reportedUserName}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DarkFeedColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Selecciona el motivo del reporte',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: DarkFeedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Tipos de reporte
          ...ReportType.values.map((tipo) => _buildTypeOption(tipo)),
          const SizedBox(height: 16),

          // Descripción adicional (opcional)
          Container(
            decoration: BoxDecoration(
              color: DarkFeedColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DarkFeedColors.borderSubtle),
            ),
            child: TextField(
              controller: _descriptionController,
              style: GoogleFonts.inter(
                  color: DarkFeedColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Detalles adicionales... (opcional)',
                hintStyle: GoogleFonts.inter(
                  color: DarkFeedColors.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
              maxLines: 3,
              maxLength: 200,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                  Text('$currentLength/$maxLength',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: DarkFeedColors.textSecondary)),
            ),
          ),
          const SizedBox(height: 20),

          // Botón enviar
          GestureDetector(
            onTap: (_selectedType == null || _isSubmitting) ? null : _submit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: _selectedType != null
                    ? DarkFeedColors.errorRed
                    : DarkFeedColors.borderSubtle,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Enviar reporte',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(ReportType tipo) {
    final isSelected = _selectedType == tipo;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = tipo),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? DarkFeedColors.errorRed.withValues(alpha: 0.1)
              : DarkFeedColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? DarkFeedColors.errorRed
                : DarkFeedColors.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: isSelected
                  ? DarkFeedColors.errorRed
                  : DarkFeedColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              ReportModel.labelForType(tipo),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? DarkFeedColors.textPrimary
                    : DarkFeedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedType == null) return;

    setState(() => _isSubmitting = true);

    try {
      final report = ReportModel(
        id: '',
        reporterId: user.uid,
        reporterName: user.displayName ?? 'Usuario',
        reportedUserId: widget.reportedUserId,
        reportedUserName: widget.reportedUserName,
        tipo: _selectedType!,
        descripcion: _descriptionController.text.trim(),
        estado: ReportStatus.nuevo,
        fechaCreacion: DateTime.now(),
      );

      await ref.read(reportRepositoryProvider).createReport(report);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reporte enviado. Lo revisaremos pronto.',
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
