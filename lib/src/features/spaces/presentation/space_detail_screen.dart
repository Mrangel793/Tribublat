import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/spaces/data/space_repository.dart';
import 'package:myapp/src/features/spaces/domain/business_space_model.dart';

class SpaceDetailScreen extends ConsumerWidget {
  final String spaceId;
  const SpaceDetailScreen({super.key, required this.spaceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaceAsync = ref.watch(spaceStreamProvider(spaceId));

    return spaceAsync.when(
      loading: () => const Scaffold(
        backgroundColor: DarkFeedColors.background,
        body: Center(
            child: CircularProgressIndicator(
                color: DarkFeedColors.gradientOrange)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: DarkFeedColors.background,
        appBar: AppBar(backgroundColor: DarkFeedColors.background),
        body: Center(child: Text('Error: $e')),
      ),
      data: (space) {
        if (space == null) {
          return Scaffold(
            backgroundColor: DarkFeedColors.background,
            appBar: AppBar(backgroundColor: DarkFeedColors.background),
            body: const Center(child: Text('Espacio no encontrado')),
          );
        }
        return _buildDetail(context, space);
      },
    );
  }

  Widget _buildDetail(BuildContext context, BusinessSpaceModel space) {
    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: DarkFeedColors.background,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: DarkFeedColors.surface,
                    child: const Icon(Icons.store,
                        size: 80, color: DarkFeedColors.borderSubtle),
                  ),
                  if (space.esPremium)
                    Positioned(
                      top: 60,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: DarkFeedColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('Espacio destacado',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y categoría
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          space.nombre,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: DarkFeedColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DarkFeedColors.gradientViolet
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          BusinessSpaceModel.labelForCategory(
                              space.categoria),
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: DarkFeedColors.gradientViolet,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Dirección
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 15,
                          color: DarkFeedColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${space.direccion}, ${space.ciudad}',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: DarkFeedColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    children: [
                      _statChip(Icons.star_rounded,
                          space.puntuacionPromedio.toStringAsFixed(1),
                          '(${space.totalResenas} reseñas)',
                          const Color(0xFFFFD700)),
                      const SizedBox(width: 12),
                      _statChip(Icons.event_outlined,
                          '${space.totalEventos}', 'eventos',
                          DarkFeedColors.gradientOrange),
                      const SizedBox(width: 12),
                      _statChip(Icons.people_outline,
                          '${space.totalAsistentes}', 'asistentes',
                          DarkFeedColors.greenEmerald),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Descripción
                  Text('Sobre el espacio',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DarkFeedColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(space.descripcion,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: DarkFeedColors.textSecondary,
                          height: 1.5)),
                  const SizedBox(height: 20),

                  // Disponibilidad
                  if (space.disponibilidad.isNotEmpty) ...[
                    Text('Horarios disponibles',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: DarkFeedColors.textPrimary)),
                    const SizedBox(height: 10),
                    ...space.disponibilidad
                        .map((f) => _buildFranjaItem(f)),
                    const SizedBox(height: 20),
                  ],

                  // Contacto
                  if (space.telefono.isNotEmpty ||
                      space.web.isNotEmpty) ...[
                    Text('Contacto',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: DarkFeedColors.textPrimary)),
                    const SizedBox(height: 10),
                    if (space.telefono.isNotEmpty)
                      _contactRow(Icons.phone_outlined, space.telefono),
                    if (space.web.isNotEmpty)
                      _contactRow(Icons.language_outlined, space.web),
                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        color: DarkFeedColors.surface,
        child: GestureDetector(
          onTap: () => context.push('/create-plan',
              extra: {'spaceId': space.id, 'spaceName': space.nombre}),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              gradient: DarkFeedColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Crear plan en este espacio',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DarkFeedColors.textPrimary)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: DarkFeedColors.textSecondary)),
      ],
    );
  }

  Widget _buildFranjaItem(DisponibilidadFranja f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DarkFeedColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Row(
        children: [
          Text(f.diaLabel,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DarkFeedColors.textPrimary)),
          const Spacer(),
          Text('${f.horaInicio} – ${f.horaFin}',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: DarkFeedColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: DarkFeedColors.textSecondary),
          const SizedBox(width: 8),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 14, color: DarkFeedColors.textPrimary)),
        ],
      ),
    );
  }
}
