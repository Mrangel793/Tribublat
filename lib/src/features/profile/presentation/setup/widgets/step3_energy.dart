import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';
import 'package:myapp/src/features/profile/presentation/setup/controllers/profile_setup_controller.dart';

class Step3Energy extends HookConsumerWidget {
  const Step3Energy({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileSetupControllerProvider);
    final controller = ref.read(profileSetupControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            '¿Cuál es tu energía social?',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esto nos ayuda a recomendarte planes acordes a tu estilo',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),

          // Opciones de energía
          _EnergyOption(
            level: EnergyLevel.baja,
            isSelected: state.nivelEnergia == EnergyLevel.baja,
            onTap: () => controller.setNivelEnergia(EnergyLevel.baja),
            emoji: '🌙',
            title: 'Tranquilo',
            description: 'Prefiero actividades relajadas con grupos pequeños. Me gusta conocer personas en ambientes calmados.',
            examples: ['Cafés', 'Cenas', 'Paseos', 'Charlas'],
            color: const Color(0xFF6C5CE7),
          ),
          const SizedBox(height: 16),

          _EnergyOption(
            level: EnergyLevel.media,
            isSelected: state.nivelEnergia == EnergyLevel.media,
            onTap: () => controller.setNivelEnergia(EnergyLevel.media),
            emoji: '⚡',
            title: 'Equilibrado',
            description: 'Me adapto bien a diferentes ambientes. Disfruto tanto de planes tranquilos como activos.',
            examples: ['Deportes', 'Conciertos', 'Reuniones', 'Viajes'],
            color: const Color(0xFF4ECDC4),
          ),
          const SizedBox(height: 16),

          _EnergyOption(
            level: EnergyLevel.alta,
            isSelected: state.nivelEnergia == EnergyLevel.alta,
            onTap: () => controller.setNivelEnergia(EnergyLevel.alta),
            emoji: '🔥',
            title: 'Activo',
            description: 'Me encanta la acción y los grupos grandes. Busco experiencias emocionantes y mucha interacción.',
            examples: ['Fiestas', 'Aventuras', 'Festivales', 'Baile'],
            color: const Color(0xFFFF6B9D),
          ),

          const SizedBox(height: 40),

          // Indicador visual
          _EnergyMeter(currentLevel: state.nivelEnergia),
        ],
      ),
    );
  }
}

class _EnergyOption extends StatelessWidget {
  final EnergyLevel level;
  final bool isSelected;
  final VoidCallback onTap;
  final String emoji;
  final String title;
  final String description;
  final List<String> examples;
  final Color color;

  const _EnergyOption({
    required this.level,
    required this.isSelected,
    required this.onTap,
    required this.emoji,
    required this.title,
    required this.description,
    required this.examples,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Emoji con fondo
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getLevelText(level),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Indicador de selección
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: examples.map((example) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    example,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isSelected ? color : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getLevelText(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.baja:
        return 'Energía baja';
      case EnergyLevel.media:
        return 'Energía media';
      case EnergyLevel.alta:
        return 'Energía alta';
    }
  }
}

class _EnergyMeter extends StatelessWidget {
  final EnergyLevel currentLevel;

  const _EnergyMeter({required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Tu nivel de energía',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMeterSegment(
                EnergyLevel.baja,
                '🌙',
                const Color(0xFF6C5CE7),
              ),
              const SizedBox(width: 8),
              _buildMeterSegment(
                EnergyLevel.media,
                '⚡',
                const Color(0xFF4ECDC4),
              ),
              const SizedBox(width: 8),
              _buildMeterSegment(
                EnergyLevel.alta,
                '🔥',
                const Color(0xFFFF6B9D),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeterSegment(EnergyLevel level, String emoji, Color color) {
    final isActive = currentLevel == level;
    final isPast = currentLevel.index >= level.index;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 50,
        decoration: BoxDecoration(
          color: isPast ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isActive ? 1.3 : 1.0,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
