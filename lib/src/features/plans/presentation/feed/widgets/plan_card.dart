import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/common/widgets/base64_image_widget.dart';
import 'package:myapp/src/features/plans/domain/models/plan_model.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

/// Card principal para mostrar un plan en el feed (Dark Mode)
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
    final isSponsored = plan.estaDestacadoActivo;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: DarkFeedColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSponsored
                ? plan.tipoDestacado.color
                : DarkFeedColors.borderSubtle.withOpacity(0.5),
            width: isSponsored ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titulo
                  Text(
                    plan.titulo,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: DarkFeedColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Info row
                  _buildInfoRow(),
                  const SizedBox(height: 12),

                  // Match bar
                  if (matchPercentage != null && matchPercentage! > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMatchBar(),
                    ),

                  // Bottom: avatares + boton
                  _buildBottomRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== IMAGEN ==========

  Widget _buildImageSection() {
    final categoryInfo = PlanConstants.getCategoryByEnum(plan.categoria);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: plan.imagenBase64.isNotEmpty
              ? Base64ImageWidget(
                  base64String: plan.imagenBase64,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        DarkFeedColors.surface,
                        DarkFeedColors.cardBackground,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      categoryInfo?.emoji ?? '📌',
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
        ),

        // Overlay gradiente oscuro inferior
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  DarkFeedColors.cardBackground.withOpacity(0.9),
                ],
              ),
            ),
          ),
        ),

        // Badge energia (top-right)
        Positioned(
          top: 10,
          right: 10,
          child: _buildEnergyBadge(),
        ),

        // Badge categoria (top-left)
        Positioned(
          top: 10,
          left: 10,
          child: _buildCategoryBadge(categoryInfo),
        ),

        // Badge sponsored
        if (plan.estaDestacadoActivo)
          Positioned(
            top: 44,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    plan.tipoDestacado.color,
                    plan.tipoDestacado.color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 12),
                  const SizedBox(width: 3),
                  Text(
                    plan.tipoDestacado.nombre,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEnergyBadge() {
    String emoji;
    String label;
    switch (plan.nivelEnergia) {
      case EnergyLevel.baja:
        emoji = '🌙';
        label = 'Night';
      case EnergyLevel.media:
        emoji = '⚡';
        label = 'Medium';
      case EnergyLevel.alta:
        emoji = '🔥';
        label = 'Hot';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: DarkFeedColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(PlanCategoryInfo? categoryInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(categoryInfo?.emoji ?? '📌', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            categoryInfo?.nombre ?? 'Otro',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: DarkFeedColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ========== INFO ROW ==========

  Widget _buildInfoRow() {
    final dateFormat = DateFormat('dd MMM · HH:mm', 'es');
    final formattedDate = dateFormat.format(plan.fechaHora);
    final location = plan.ubicacionNombre.isNotEmpty ? plan.ubicacionNombre : plan.ciudad;

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _infoItem(Icons.location_on, location),
        _infoItem(Icons.calendar_today, formattedDate),
        _infoItem(Icons.people, '${plan.capacidadActual}/${plan.capacidadMaxima}'),
      ],
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: DarkFeedColors.textSecondary),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: DarkFeedColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ========== MATCH BAR ==========

  Widget _buildMatchBar() {
    final percentage = matchPercentage ?? 0;
    final isHighMatch = percentage >= 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isHighMatch ? 'SUPER MATCH' : 'MATCH PROBABLE',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: DarkFeedColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DarkFeedColors.gradientOrange,
              ),
            ),
            const Spacer(),
            Text(
              plan.precioFormateado,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: plan.tipoPrecio == PlanPriceType.gratis
                    ? DarkFeedColors.greenEmerald
                    : DarkFeedColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: DarkFeedColors.borderSubtle,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (percentage / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: DarkFeedColors.primaryGradient,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ========== BOTTOM ROW ==========

  Widget _buildBottomRow() {
    return Row(
      children: [
        _buildOverlappingAvatars(),
        if (plan.participantesIds.length > 3)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '+${plan.participantesIds.length - 3} más',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: DarkFeedColors.textSecondary,
              ),
            ),
          ),
        const Spacer(),
        _buildJoinButton(),
      ],
    );
  }

  Widget _buildOverlappingAvatars() {
    final ids = plan.participantesIds.take(3).toList();
    if (ids.isEmpty) return const SizedBox.shrink();

    final colors = [
      const Color(0xFF6C5CE7),
      const Color(0xFF00CEC9),
      const Color(0xFFFD79A8),
    ];

    return SizedBox(
      width: 20.0 + (ids.length - 1) * 16.0,
      height: 28,
      child: Stack(
        children: [
          for (int i = 0; i < ids.length; i++)
            Positioned(
              left: i * 16.0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[i % colors.length],
                  border: Border.all(
                    color: DarkFeedColors.cardBackground,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    ids[i].isNotEmpty ? ids[i][0].toUpperCase() : '?',
                    style: GoogleFonts.inter(
                      fontSize: 10,
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

  Widget _buildJoinButton() {
    if (isLoading) {
      return SizedBox(
        width: 90,
        height: 34,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: DarkFeedColors.greenEmerald,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero,
          ),
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (isUserJoined) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: DarkFeedColors.greenEmerald),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: DarkFeedColors.greenEmerald, size: 14),
            const SizedBox(width: 4),
            Text(
              'Unido',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DarkFeedColors.greenEmerald,
              ),
            ),
          ],
        ),
      );
    }

    if (isInWaitingList) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: DarkFeedColors.warningOrange),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'En espera',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: DarkFeedColors.warningOrange,
          ),
        ),
      );
    }

    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onJoin,
        style: ElevatedButton.styleFrom(
          backgroundColor: DarkFeedColors.greenEmerald,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          plan.tieneDisponibilidad ? 'Unirme' : 'Lista de espera',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
