import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:myapp/src/features/plans/presentation/create/controllers/create_plan_controller.dart';

/// Widget que muestra las opciones de plan destacado (solo para negocios)
class SponsorOptionsWidget extends ConsumerWidget {
  const SponsorOptionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPlanControllerProvider);
    final controller = ref.read(createPlanControllerProvider.notifier);

    // No mostrar si el usuario no puede destacar
    if (!state.puedeDestacar) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DarkFeedColors.gradientOrange.withOpacity(0.08),
            DarkFeedColors.gradientViolet.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DarkFeedColors.gradientOrange.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con badge de negocio
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: DarkFeedColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Negocio',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Opciones de promocion',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DarkFeedColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Toggle de plan destacado
          _buildSponsorToggle(state, controller),

          // Opciones adicionales si esta destacado
          if (state.esDestacado) ...[
            const SizedBox(height: 16),
            _buildTierSelector(state, controller),
            const SizedBox(height: 16),
            _buildDurationSelector(state, controller),
            const SizedBox(height: 12),
            _buildSponsorInfo(state),
          ],
        ],
      ),
    );
  }

  Widget _buildSponsorToggle(
      CreatePlanState state, CreatePlanController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DarkFeedColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: state.esDestacado
              ? DarkFeedColors.gradientOrange
              : DarkFeedColors.borderSubtle,
          width: state.esDestacado ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DarkFeedColors.gradientOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.campaign,
              color: DarkFeedColors.gradientOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Destacar este plan',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DarkFeedColors.textPrimary,
                  ),
                ),
                Text(
                  'Mayor visibilidad en el feed',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: DarkFeedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: state.esDestacado,
            onChanged: controller.setEsDestacado,
            activeColor: DarkFeedColors.gradientOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildTierSelector(
      CreatePlanState state, CreatePlanController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nivel de promocion',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: DarkFeedColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SponsorTier.basico,
            SponsorTier.premium,
            SponsorTier.exclusivo,
          ]
              .map((tier) => _buildTierChip(tier, state, controller))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTierChip(
    SponsorTier tier,
    CreatePlanState state,
    CreatePlanController controller,
  ) {
    final isSelected = state.tipoDestacado == tier;
    final color = tier.color;

    return GestureDetector(
      onTap: () => controller.setTipoDestacado(tier),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : DarkFeedColors.cardBackground.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : DarkFeedColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : tier.icon,
              color: isSelected ? color : DarkFeedColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              tier.nombre,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : DarkFeedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector(
      CreatePlanState state, CreatePlanController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duracion del destacado',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: DarkFeedColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildDurationOption(7, state, controller),
            const SizedBox(width: 8),
            _buildDurationOption(14, state, controller),
            const SizedBox(width: 8),
            _buildDurationOption(30, state, controller),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationOption(
    int dias,
    CreatePlanState state,
    CreatePlanController controller,
  ) {
    final isSelected = state.diasDestacado == dias;

    return GestureDetector(
      onTap: () => controller.setDiasDestacado(dias),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? DarkFeedColors.gradientViolet.withOpacity(0.15)
              : DarkFeedColors.cardBackground.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? DarkFeedColors.gradientViolet
                : DarkFeedColors.borderSubtle,
          ),
        ),
        child: Text(
          '$dias dias',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? DarkFeedColors.gradientViolet
                : DarkFeedColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSponsorInfo(CreatePlanState state) {
    final tier = state.tipoDestacado;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tier.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tier.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: tier.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tier.descripcion,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: DarkFeedColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
