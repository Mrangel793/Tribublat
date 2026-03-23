import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/plans/data/plan_repository.dart'
    show PlanRepository, PlanRepositoryException, planRepositoryProvider,
        planStreamProvider, JoinPlanResult;
import 'package:myapp/src/features/plans/domain/models/plan_model.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/common/widgets/base64_image_widget.dart';
import 'package:myapp/src/features/user/data/user_repository.dart';
import 'package:myapp/src/features/reviews/data/review_repository.dart';
import 'package:myapp/src/features/reviews/domain/review_model.dart';
import 'package:myapp/src/features/reviews/presentation/review_form_sheet.dart';
import 'package:share_plus/share_plus.dart';

/// Pantalla de detalle de un plan
class PlanDetailScreen extends ConsumerStatefulWidget {
  final String planId;

  const PlanDetailScreen({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<PlanDetailScreen> {
  bool _isDescriptionExpanded = false;
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planStreamProvider(widget.planId));

    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      body: planAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: DarkFeedColors.gradientOrange,
          ),
        ),
        error: (error, _) => _buildErrorState(error.toString()),
        data: (plan) {
          if (plan == null) {
            return _buildErrorState('Plan no encontrado');
          }
          return _buildContent(plan);
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: DarkFeedColors.errorRed),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 16, color: DarkFeedColors.textSecondary),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: DarkFeedColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Volver',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PlanModel plan) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isUserJoined = plan.participantesIds.contains(currentUserId);
    final isOnWaitlist = plan.listaEsperaIds.contains(currentUserId);
    final isOrganizer = plan.organizadorId == currentUserId;
    final isFull = plan.capacidadActual >= plan.capacidadMaxima;
    final categoryInfo = PlanConstants.getCategoryByEnum(plan.categoria);

    // Solicitudes pendientes (leídas de Firestore directamente)
    final solicitudesAsync = ref.watch(
      StreamProvider((ref) => ref
          .read(planRepositoryProvider)
          .watchSolicitudes(plan.id)),
    );
    final solicitudes = solicitudesAsync.valueOrNull ?? [];
    final isUserPending = solicitudes.contains(currentUserId);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildSliverAppBar(plan, categoryInfo),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildDateLocationCards(plan),
                    const SizedBox(height: 24),
                    _buildDescriptionSection(plan),
                    const SizedBox(height: 24),
                    _buildMapSection(plan),
                    const SizedBox(height: 24),
                    _buildOrganizerSection(plan),
                    const SizedBox(height: 24),
                    _buildParticipantsSection(plan),
                    // Sección de solicitudes (solo para el organizador)
                    if (isOrganizer && solicitudes.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSolicitudesSection(plan, solicitudes),
                    ],
                    const SizedBox(height: 24),
                    if (!isOrganizer) _buildAffinitySection(plan),
                    if (!isOrganizer) const SizedBox(height: 24),
                    _buildAdditionalDetails(plan),
                    const SizedBox(height: 24),
                    _buildReviewsSection(plan),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomAction(
              plan, isUserJoined, isOrganizer, isFull, isOnWaitlist,
              isUserPending: isUserPending),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SliverAppBar con imagen hero
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSliverAppBar(PlanModel plan, PlanCategoryInfo? categoryInfo) {
    final isInstant = plan.fechaHora.difference(DateTime.now()).inHours < 24;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: DarkFeedColors.background,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => _sharePlan(plan),
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.share, color: Colors.white, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen (soporta Cloudinary URL y Base64)
            if (plan.imagenBase64.isNotEmpty)
              Base64ImageWidget(
                base64String: plan.imagenBase64,
                width: double.infinity,
                fit: BoxFit.cover,
                useThumbnail: false, // Imagen completa en detalle
              )
            else
              Container(
                color: DarkFeedColors.cardBackground,
                child: Center(
                  child: Icon(
                    categoryInfo?.icon ?? Icons.event,
                    size: 80,
                    color: (categoryInfo?.color ?? DarkFeedColors.gradientViolet)
                        .withValues(alpha: 0.3),
                  ),
                ),
              ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
            // Badge + titulo
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isInstant)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: DarkFeedColors.greenEmerald,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Instantaneo',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    plan.titulo,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Fecha y ubicacion
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDateLocationCards(PlanModel plan) {
    final dateFormat = DateFormat('EEE d MMM', 'es');
    final timeFormat = DateFormat('h:mm a');
    final endTime = plan.fechaHora.add(Duration(minutes: plan.duracionMinutos));

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DarkFeedColors.cardBackground.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DarkFeedColors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: DarkFeedColors.gradientViolet.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today,
                      color: DarkFeedColors.gradientViolet, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(plan.fechaHora),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: DarkFeedColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${timeFormat.format(plan.fechaHora)} - ${timeFormat.format(endTime)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: DarkFeedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DarkFeedColors.cardBackground.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DarkFeedColors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: DarkFeedColors.gradientOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on,
                      color: DarkFeedColors.gradientOrange, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.ubicacionNombre,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: DarkFeedColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        plan.ciudad,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: DarkFeedColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Descripcion
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDescriptionSection(PlanModel plan) {
    final maxLines = _isDescriptionExpanded ? 100 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.info_outline, 'Sobre este plan'),
        const SizedBox(height: 10),
        Text(
          plan.descripcion,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: DarkFeedColors.textSecondary,
            height: 1.5,
          ),
          maxLines: maxLines,
          overflow: _isDescriptionExpanded
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
        ),
        if (plan.descripcion.length > 100)
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return DarkFeedColors.primaryGradient.createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Text(
                  _isDescriptionExpanded ? 'Ver menos' : 'Leer mas',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Mapa placeholder
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMapSection(PlanModel plan) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: DarkFeedColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.map,
                size: 60,
                color: DarkFeedColors.textSecondary.withOpacity(0.15)),
          ),
          Center(
            child: Icon(Icons.location_on,
                size: 40, color: DarkFeedColors.errorRed.withOpacity(0.7)),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // TODO: Abrir en Google Maps
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: DarkFeedColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DarkFeedColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return DarkFeedColors.primaryGradient
                              .createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: const Icon(Icons.navigation,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return DarkFeedColors.primaryGradient
                              .createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          'Abrir en Maps',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Organizador
  // ═══════════════════════════════════════════════════════════════
  Widget _buildOrganizerSection(PlanModel plan) {
    return GestureDetector(
      onTap: () => context.push('/profile/${plan.organizadorId}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DarkFeedColors.cardBackground.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DarkFeedColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: DarkFeedColors.primaryGradient,
              ),
              padding: const EdgeInsets.all(2),
              child: Base64CircleAvatar(
                base64String: plan.organizadorFoto,
                radius: 22,
                backgroundColor: DarkFeedColors.surface,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.organizadorNombre,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: DarkFeedColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Organizador',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: DarkFeedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFFD700), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    plan.organizadorReputacion.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Participantes
  // ═══════════════════════════════════════════════════════════════
  Widget _buildParticipantsSection(PlanModel plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(
                Icons.group, 'Quien va (${plan.capacidadActual})'),
            GestureDetector(
              onTap: () {
                // TODO: Ver todos los participantes
              },
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return DarkFeedColors.primaryGradient.createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Text(
                  'Ver todos',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: Stack(
            children: [
              ...List.generate(
                plan.participantesIds.length > 5
                    ? 5
                    : plan.participantesIds.length,
                (index) => Positioned(
                  left: index * 30.0,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: DarkFeedColors.background, width: 3),
                      gradient: LinearGradient(
                        colors: [
                          DarkFeedColors.gradientOrange
                              .withOpacity(0.3 + (index * 0.1)),
                          DarkFeedColors.gradientViolet
                              .withOpacity(0.3 + (index * 0.1)),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
              if (plan.participantesIds.length > 5)
                Positioned(
                  left: 5 * 30.0,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: DarkFeedColors.background, width: 3),
                      color: DarkFeedColors.surface,
                    ),
                    child: Center(
                      child: Text(
                        '+${plan.participantesIds.length - 5}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DarkFeedColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Afinidad
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAffinitySection(PlanModel plan) {
    final affinityPercentage = 85;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DarkFeedColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: DarkFeedColors.gradientViolet.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: DarkFeedColors.primaryGradient,
            ),
            child: Center(
              child: Text(
                '$affinityPercentage%',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'de afinidad',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DarkFeedColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                _buildAffinityItem(Icons.favorite, 'Intereses comunes: 7/10'),
                _buildAffinityItem(Icons.bolt, 'Energia similar'),
                _buildAffinityItem(Icons.star, 'En tu zona de confort'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAffinityItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return DarkFeedColors.primaryGradient.createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: DarkFeedColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Detalles adicionales
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAdditionalDetails(PlanModel plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.list_alt, 'Detalles adicionales'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DarkFeedColors.cardBackground.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DarkFeedColors.borderSubtle),
          ),
          child: Column(
            children: [
              _buildDetailRow(Icons.attach_money, 'Costo',
                  plan.tipoPrecio == PlanPriceType.gratis
                      ? 'Gratis'
                      : '\$${plan.precio.toStringAsFixed(0)} COP'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                    height: 1,
                    color: DarkFeedColors.borderSubtle.withOpacity(0.5)),
              ),
              _buildDetailRow(
                  Icons.directions, 'Como llegar', 'Parking disponible'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                    height: 1,
                    color: DarkFeedColors.borderSubtle.withOpacity(0.5)),
              ),
              _buildDetailRow(Icons.timer, 'Duracion',
                  '${(plan.duracionMinutos / 60).toStringAsFixed(0)} horas'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                    height: 1,
                    color: DarkFeedColors.borderSubtle.withOpacity(0.5)),
              ),
              _buildDetailRow(
                  Icons.info_outline, 'Requisitos', 'Ser mayor de 18'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: DarkFeedColors.gradientViolet, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: DarkFeedColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DarkFeedColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Boton inferior
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomAction(PlanModel plan, bool isUserJoined, bool isOrganizer,
      bool isFull, bool isOnWaitlist, {bool isUserPending = false}) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DarkFeedColors.background.withOpacity(0.0),
            DarkFeedColors.background,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner lista de espera
          if (isOnWaitlist)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB347).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFFFB347).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.queue_outlined,
                      size: 18, color: Color(0xFFFFB347)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Estás en la lista de espera. Te avisaremos si se libera un cupo.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFFFB347),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _confirmCancelWaitlist(plan),
                    child: Text(
                      'Salir',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFB347),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Boton principal
          GestureDetector(
            onTap: (_isJoining || isUserPending)
                ? null
                : () {
                    if (isOrganizer) {
                      context.push('/edit-plan/${plan.id}');
                    } else if (isUserJoined) {
                      _confirmLeave(plan);
                    } else {
                      _handleJoinLeave(plan, isUserJoined, isOrganizer);
                    }
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: (isOrganizer || isUserJoined || isOnWaitlist ||
                        isFull || isUserPending)
                    ? null
                    : DarkFeedColors.primaryGradient,
                color: isOrganizer
                    ? DarkFeedColors.gradientViolet
                    : (isUserJoined
                        ? DarkFeedColors.errorRed
                        : (isUserPending
                            ? DarkFeedColors.gradientViolet
                            : (isOnWaitlist
                                ? const Color(0xFFFFB347)
                                : (isFull
                                    ? DarkFeedColors.borderSubtle
                                    : null)))),
                borderRadius: BorderRadius.circular(16),
                boxShadow: (!isUserJoined && !isFull)
                    ? [
                        BoxShadow(
                          color:
                              DarkFeedColors.gradientOrange.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: _isJoining
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        isOrganizer
                            ? 'Editar plan'
                            : (isUserJoined
                                ? 'Cancelar asistencia'
                                : (isUserPending
                                    ? 'Solicitud enviada ⏳'
                                    : (isOnWaitlist
                                        ? 'En lista de espera'
                                        : (isFull
                                            ? 'Plan lleno'
                                            : plan.requiereAprobacion
                                                ? 'Solicitar asistencia'
                                                : 'Unirme al plan')))),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          // Botón "Dejar reseña" (solo participantes después del evento)
          if (isUserJoined &&
              plan.fechaHora.isBefore(DateTime.now())) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showReviewSheet(plan),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_outline_rounded,
                        size: 20, color: Color(0xFFFFD700)),
                    const SizedBox(width: 8),
                    Text(
                      'Dejar reseña',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // Botón de chat (solo participantes y organizador)
          if (isUserJoined || isOrganizer) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => context.push('/plan/${plan.id}/chat'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: DarkFeedColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DarkFeedColors.borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          DarkFeedColors.primaryGradient.createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: const Icon(Icons.chat_bubble_outline,
                          size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          DarkFeedColors.primaryGradient.createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        'Chat del plan',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (!isOrganizer)
            GestureDetector(
              onTap: () {
                // TODO: Reportar plan
              },
              child: Text(
                'Reportar plan',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: DarkFeedColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Reseñas
  // ═══════════════════════════════════════════════════════════════
  Widget _buildReviewsSection(PlanModel plan) {
    final reviewsAsync = ref.watch(planReviewsProvider(plan.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle(Icons.star_rounded, 'Reseñas'),
            const SizedBox(width: 8),
            if (plan.puntuacionPromedio > 0) ...[
              Text(
                plan.puntuacionPromedio.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star_rounded,
                  size: 20, color: Color(0xFFFFD700)),
            ],
          ],
        ),
        const SizedBox(height: 12),
        reviewsAsync.when(
          loading: () => const SizedBox(
            height: 60,
            child: Center(
                child: CircularProgressIndicator(
                    color: DarkFeedColors.gradientOrange)),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (reviews) {
            if (reviews.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DarkFeedColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: DarkFeedColors.borderSubtle),
                ),
                child: Text(
                  'Sin reseñas todavía. ¡Sé el primero en opinar!',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: DarkFeedColors.textSecondary,
                  ),
                ),
              );
            }
            return Column(
              children: reviews
                  .take(3)
                  .map((r) => _buildReviewItem(r))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DarkFeedColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    DarkFeedColors.gradientViolet.withValues(alpha: 0.3),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DarkFeedColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${review.fechaCreacion.day}/${review.fechaCreacion.month}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: DarkFeedColors.textSecondary,
                ),
              ),
            ],
          ),
          if (review.comentario.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comentario,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: DarkFeedColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Solicitudes pendientes (solo organizador)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSolicitudesSection(PlanModel plan, List<String> solicitudes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle(Icons.pending_actions, 'Solicitudes'),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: DarkFeedColors.gradientOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${solicitudes.length}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DarkFeedColors.gradientOrange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Personas que quieren unirse a tu plan',
          style: GoogleFonts.inter(
              fontSize: 12, color: DarkFeedColors.textSecondary),
        ),
        const SizedBox(height: 12),
        ...solicitudes.map((userId) => _buildSolicitudItem(plan, userId)),
      ],
    );
  }

  Widget _buildSolicitudItem(PlanModel plan, String userId) {
    // Cargar perfil real del solicitante
    final userAsync = ref.watch(
      StreamProvider((ref) =>
          ref.read(userRepositoryProvider).userProfileStream(userId)),
    );
    final solicitante = userAsync.valueOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DarkFeedColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: DarkFeedColors.gradientOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Foto del solicitante
          GestureDetector(
            onTap: () => context.push('/profile/$userId'),
            child: Base64CircleAvatar(
              base64String: solicitante?.foto ?? '',
              radius: 20,
              backgroundColor:
                  DarkFeedColors.gradientViolet.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/profile/$userId'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    solicitante?.nombre ?? 'Cargando...',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DarkFeedColors.textPrimary,
                    ),
                  ),
                  if (solicitante != null)
                    Text(
                      '${solicitante.edad} años · ${solicitante.ciudad}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: DarkFeedColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Botón rechazar
          GestureDetector(
            onTap: () => _rejectSolicitud(plan, userId),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: DarkFeedColors.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: DarkFeedColors.errorRed.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Rechazar',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: DarkFeedColors.errorRed,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón aprobar
          GestureDetector(
            onTap: () => _approveSolicitud(plan, userId),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: DarkFeedColors.greenEmerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: DarkFeedColors.greenEmerald.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Aprobar',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: DarkFeedColors.greenEmerald,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveSolicitud(PlanModel plan, String userId) async {
    try {
      await ref
          .read(planRepositoryProvider)
          .approveSolicitud(plan.id, userId, '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Solicitud aprobada',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: DarkFeedColors.greenEmerald,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: DarkFeedColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  Future<void> _rejectSolicitud(PlanModel plan, String userId) async {
    await ref
        .read(planRepositoryProvider)
        .rejectSolicitud(plan.id, userId, plan.titulo);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Solicitud rechazada',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: DarkFeedColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _showReviewSheet(PlanModel plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewFormSheet(
        planId: plan.id,
        planTitulo: plan.titulo,
      ),
    );
  }

  void _sharePlan(PlanModel plan) {
    final fecha = DateFormat('EEEE dd/MM/yyyy – HH:mm', 'es').format(plan.fechaHora);
    final cupos = plan.tieneDisponibilidad
        ? '${plan.plazasDisponibles} cupos disponibles'
        : 'Sin cupos disponibles';

    final texto = '''🎉 *${plan.titulo}*

📅 $fecha
📍 ${plan.ubicacionNombre.isNotEmpty ? plan.ubicacionNombre : plan.ciudad}
👥 $cupos
${plan.tipoPrecio == PlanPriceType.gratis ? '✅ Gratis' : '💰 ${plan.precioFormateado}'}

${plan.descripcion}

¡Únete en TribuLat! 🚀''';

    Share.share(texto, subject: plan.titulo);
  }

  // ═══════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return DarkFeedColors.primaryGradient.createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DarkFeedColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _confirmLeave(PlanModel plan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: DarkFeedColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '¿Cancelar asistencia?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: DarkFeedColors.textPrimary,
          ),
        ),
        content: Text(
          'Si cancelas, perderás tu cupo en "${plan.titulo}". Si hay lista de espera, tu lugar pasará al siguiente.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: DarkFeedColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Quedarme',
              style: GoogleFonts.inter(color: DarkFeedColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleJoinLeave(plan, true, false);
            },
            child: Text(
              'Cancelar asistencia',
              style: GoogleFonts.inter(
                color: DarkFeedColors.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancelWaitlist(PlanModel plan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: DarkFeedColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '¿Salir de la lista de espera?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: DarkFeedColors.textPrimary,
          ),
        ),
        content: Text(
          'Perderás tu lugar en la lista de espera de "${plan.titulo}".',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: DarkFeedColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(
                    color: DarkFeedColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleJoinLeave(plan, false, false);
            },
            child: Text(
              'Salir de lista',
              style: GoogleFonts.inter(
                color: DarkFeedColors.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleJoinLeave(
      PlanModel plan, bool isUserJoined, bool isOrganizer) async {
    if (isOrganizer) {
      // TODO: Navegar a editar plan
      return;
    }

    setState(() => _isJoining = true);

    try {
      final repository = ref.read(planRepositoryProvider);
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Debes iniciar sesion',
                  style: GoogleFonts.inter(color: Colors.white)),
              backgroundColor: DarkFeedColors.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      if (isUserJoined) {
        await repository.leavePlan(plan.id, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Has salido del plan',
                  style: GoogleFonts.inter(color: Colors.white)),
              backgroundColor: DarkFeedColors.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        final result = await repository.joinPlan(plan.id, userId);
        if (mounted) {
          switch (result) {
            case JoinPlanResult.joined:
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('¡Te has unido al plan!',
                    style: GoogleFonts.inter(color: Colors.white)),
                backgroundColor: DarkFeedColors.greenEmerald,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
              break;
            case JoinPlanResult.solicitudEnviada:
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    '¡Solicitud enviada! El coordinador la revisará pronto.',
                    style: GoogleFonts.inter(color: Colors.white)),
                backgroundColor: DarkFeedColors.gradientViolet,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
              break;
            case JoinPlanResult.listaEspera:
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Plan lleno. Te agregamos a la lista de espera.',
                    style: GoogleFonts.inter(color: Colors.white)),
                backgroundColor: const Color(0xFFFFB347),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
              break;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: DarkFeedColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }
}

// planStreamProvider está definido en plan_repository.dart
