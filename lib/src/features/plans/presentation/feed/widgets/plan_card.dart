import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/common/widgets/base64_image_widget.dart';
import 'package:myapp/src/features/plans/domain/models/plan_model.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'match_badge.dart';
import 'category_badge.dart';
import 'energy_tag.dart';
import 'capacity_indicator.dart';
import 'organizer_row.dart';
import 'plan_action_button.dart';

/// Card principal para mostrar un plan en el feed
class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final int? matchPercentage;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final bool isUserJoined;
  final bool isInWaitingList;
  final bool isLoading;
  final double? groupAffinity;

  const PlanCard({
    super.key,
    required this.plan,
    this.matchPercentage,
    required this.onTap,
    required this.onJoin,
    required this.isUserJoined,
    required this.isInWaitingList,
    this.isLoading = false,
    this.groupAffinity,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(38),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con badges
            _buildImageSection(),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    plan.titulo,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3436),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Energy tag + Capacity + Price
                  _buildInfoRow(),

                  const SizedBox(height: 14),

                  // Organizador
                  OrganizerRow(
                    name: plan.organizadorNombre,
                    photo: plan.organizadorFoto,
                    rating: plan.organizadorReputacion,
                    groupAffinity: groupAffinity,
                  ),

                  const SizedBox(height: 14),

                  // Botón de acción
                  PlanActionButton(
                    isJoined: isUserJoined,
                    isInWaitingList: isInWaitingList,
                    isFull: !plan.tieneDisponibilidad,
                    onPressed: onJoin,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final categoryInfo = PlanConstants.getCategoryByEnum(plan.categoria);

    return Stack(
      children: [
        // Imagen principal
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: plan.imagenBase64.isNotEmpty
              ? Base64ImageWidget(
                  base64String: plan.imagenBase64,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: double.infinity,
                  height: 180,
                  color: const Color(0xFFE0E0E0),
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      size: 60,
                      color: Color(0xFF636E72),
                    ),
                  ),
                ),
        ),

        // Badge de match (arriba izquierda)
        if (matchPercentage != null && matchPercentage! > 0)
          Positioned(
            top: 12,
            left: 12,
            child: MatchBadge(percentage: matchPercentage!),
          ),

        // Badge de categoría (arriba derecha)
        Positioned(
          top: 12,
          right: 12,
          child: CategoryBadge(
            name: categoryInfo?.nombre ?? 'Otro',
            emoji: categoryInfo?.emoji ?? '📌',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        EnergyTag(level: plan.nivelEnergia),
        const SizedBox(width: 12),
        CapacityIndicator(
          current: plan.capacidadActual,
          max: plan.capacidadMaxima,
        ),
        const Spacer(),
        Text(
          plan.precioFormateado,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: plan.tipoPrecio == PlanPriceType.gratis
                ? const Color(0xFF4ECDC4)
                : const Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }
}
