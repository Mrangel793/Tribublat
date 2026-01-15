import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/features/plans/presentation/create/controllers/create_plan_controller.dart';

class Step2Detalles extends ConsumerWidget {
  const Step2Detalles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPlanControllerProvider);
    final controller = ref.read(createPlanControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Fecha y hora'),
          const SizedBox(height: 8),
          Text(
            'Cuando se realizara tu plan?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 20),
          _buildDatePicker(context, state.fecha, controller.setFecha),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  context,
                  label: 'Hora de inicio',
                  icon: Icons.access_time,
                  value: state.horaInicio,
                  onSelect: controller.setHoraInicio,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(
                  context,
                  label: 'Hora de fin',
                  icon: Icons.access_time_filled,
                  value: state.horaFin,
                  onSelect: controller.setHoraFin,
                  isOptional: true,
                ),
              ),
            ],
          ),
          if (state.horaInicio != null && state.horaFin != null) ...[
            const SizedBox(height: 16),
            _buildDurationInfo(state.duracionMinutos),
          ],
          const SizedBox(height: 32),
          _buildQuickDateButtons(context, controller.setFecha),
          const SizedBox(height: 100), // Espacio para el footer
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3436),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    DateTime? selectedDate,
    Function(DateTime?) onSelect,
  ) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es');

    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          locale: const Locale('es'),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF9B59B6),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF2D3436),
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          onSelect(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedDate != null
                ? const Color(0xFF9B59B6)
                : const Color(0xFFE0E0E0),
            width: selectedDate != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Color(0xFF9B59B6),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF636E72),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedDate != null
                        ? dateFormat.format(selectedDate)
                        : 'Selecciona una fecha',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: selectedDate != null
                          ? const Color(0xFF2D3436)
                          : const Color(0xFFB2BEC3),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF636E72),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context, {
    required String label,
    required IconData icon,
    required DateTime? value,
    required Function(DateTime?) onSelect,
    bool isOptional = false,
  }) {
    final timeFormat = DateFormat('HH:mm');

    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: value != null
              ? TimeOfDay.fromDateTime(value)
              : TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF9B59B6),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF2D3436),
                ),
              ),
              child: child!,
            );
          },
        );
        if (time != null) {
          final now = DateTime.now();
          onSelect(DateTime(now.year, now.month, now.day, time.hour, time.minute));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                value != null ? const Color(0xFF9B59B6) : const Color(0xFFE0E0E0),
            width: value != null ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF9B59B6),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF636E72),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (isOptional)
              Text(
                '(opcional)',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: const Color(0xFFB2BEC3),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              value != null ? timeFormat.format(value) : '--:--',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: value != null
                    ? const Color(0xFF2D3436)
                    : const Color(0xFFB2BEC3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationInfo(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    String durationText;
    if (hours > 0 && mins > 0) {
      durationText = '$hours h $mins min';
    } else if (hours > 0) {
      durationText = '$hours h';
    } else {
      durationText = '$mins min';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4ECDC4).withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer_outlined,
            color: Color(0xFF4ECDC4),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Duracion estimada: $durationText',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4ECDC4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateButtons(
    BuildContext context,
    Function(DateTime?) onSelect,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final thisWeekend = _getNextWeekend(today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acceso rapido',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF636E72),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuickButton(
              label: 'Hoy',
              icon: Icons.today,
              onTap: () => onSelect(today),
            ),
            const SizedBox(width: 8),
            _buildQuickButton(
              label: 'Manana',
              icon: Icons.event,
              onTap: () => onSelect(tomorrow),
            ),
            const SizedBox(width: 8),
            _buildQuickButton(
              label: 'Finde',
              icon: Icons.weekend,
              onTap: () => onSelect(thisWeekend),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(26),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF9B59B6), size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2D3436),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _getNextWeekend(DateTime date) {
    final daysUntilSaturday = (DateTime.saturday - date.weekday) % 7;
    if (daysUntilSaturday == 0 && date.weekday == DateTime.saturday) {
      return date;
    }
    return date.add(Duration(days: daysUntilSaturday == 0 ? 7 : daysUntilSaturday));
  }
}
