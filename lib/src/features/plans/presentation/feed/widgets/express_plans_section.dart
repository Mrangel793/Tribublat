import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/plans/domain/models/plan_model.dart';

/// Seccion horizontal de "Planes Express" para el feed dark mode.
/// Muestra planes instantaneos/express en tarjetas con scroll horizontal.
class ExpressPlansSection extends StatelessWidget {
  final List<PlanModel> plans;
  final void Function(PlanModel plan) onPlanTap;

  const ExpressPlansSection({
    super.key,
    required this.plans,
    required this.onPlanTap,
  });

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Planes Express ⚡',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DarkFeedColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: navegar a lista completa de planes express
                },
                child: Text(
                  'Ver todo',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DarkFeedColors.gradientOrange,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal scrolling list
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: plans.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _ExpressCard(
                plan: plans[index],
                onTap: () => onPlanTap(plans[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ExpressCard extends StatelessWidget {
  final PlanModel plan;
  final VoidCallback onTap;

  const _ExpressCard({
    required this.plan,
    required this.onTap,
  });

  String _formatTimeRemaining() {
    final diff = plan.fechaHora.difference(DateTime.now());

    if (diff.isNegative) return 'En curso';

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours >= 1) {
      return 'Empieza en ${hours}h ${minutes}m';
    }
    return 'En ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final capacityRatio = plan.capacidadMaxima > 0
        ? plan.capacidadActual / plan.capacidadMaxima
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              DarkFeedColors.cardBackground,
              DarkFeedColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DarkFeedColors.gradientOrange.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: DarkFeedColors.gradientOrange.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bolt icon + title
            Row(
              children: [
                const Icon(
                  Icons.bolt,
                  color: DarkFeedColors.gradientOrange,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    plan.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DarkFeedColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            // Timer showing time remaining
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: DarkFeedColors.textSecondary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimeRemaining(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: DarkFeedColors.textSecondary,
                  ),
                ),
              ],
            ),

            // Capacity progress indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.capacidadFormateada,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: DarkFeedColors.textSecondary,
                      ),
                    ),
                    if (!plan.tieneDisponibilidad)
                      Text(
                        'Lleno',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: DarkFeedColors.warningOrange,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: capacityRatio,
                    minHeight: 4,
                    backgroundColor: DarkFeedColors.borderSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      capacityRatio >= 1.0
                          ? DarkFeedColors.warningOrange
                          : DarkFeedColors.greenEmerald,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
