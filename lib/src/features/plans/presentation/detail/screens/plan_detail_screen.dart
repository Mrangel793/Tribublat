import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/features/plans/data/plan_repository.dart';
import 'package:myapp/src/features/plans/domain/models/plan_model.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      backgroundColor: Colors.white,
      body: planAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
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
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFFF6B6B)),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF636E72)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PlanModel plan) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isUserJoined = plan.participantesIds.contains(currentUserId);
    final isOrganizer = plan.organizadorId == currentUserId;
    final isFull = plan.capacidadActual >= plan.capacidadMaxima;
    final categoryInfo = PlanConstants.getCategoryByEnum(plan.categoria);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // App Bar con imagen
            _buildSliverAppBar(plan, categoryInfo),
            // Contenido
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha y ubicación cards
                    _buildDateLocationCards(plan),
                    const SizedBox(height: 24),
                    // Descripción
                    _buildDescriptionSection(plan),
                    const SizedBox(height: 24),
                    // Mapa
                    _buildMapSection(plan),
                    const SizedBox(height: 24),
                    // Organizador
                    _buildOrganizerSection(plan),
                    const SizedBox(height: 24),
                    // Participantes
                    _buildParticipantsSection(plan),
                    const SizedBox(height: 24),
                    // Afinidad (solo si no es el organizador)
                    if (!isOrganizer) _buildAffinitySection(plan),
                    if (!isOrganizer) const SizedBox(height: 24),
                    // Detalles adicionales
                    _buildAdditionalDetails(plan),
                    const SizedBox(height: 120), // Espacio para el botón
                  ],
                ),
              ),
            ),
          ],
        ),
        // Botón fijo en la parte inferior
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomAction(plan, isUserJoined, isOrganizer, isFull),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(PlanModel plan, PlanCategoryInfo? categoryInfo) {
    final isInstant = plan.fechaHora.difference(DateTime.now()).inHours < 24;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            // TODO: Compartir plan
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.share, color: Color(0xFF2D3436), size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen
            plan.imagenBase64.isNotEmpty
                ? Image.memory(
                    base64Decode(plan.imagenBase64),
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoryInfo?.color.withAlpha(200) ?? const Color(0xFF9B59B6),
                          categoryInfo?.color ?? const Color(0xFFC06BFF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      categoryInfo?.icon ?? Icons.event,
                      size: 80,
                      color: Colors.white.withAlpha(100),
                    ),
                  ),
            // Gradiente oscuro
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(180),
                  ],
                ),
              ),
            ),
            // Badge y título
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge instantáneo
                  if (isInstant)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: Colors.white, size: 16),
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
                  // Título
                  Text(
                    plan.titulo,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDateLocationCards(PlanModel plan) {
    final dateFormat = DateFormat('EEE d MMM', 'es');
    final timeFormat = DateFormat('h:mm a');
    final endTime = plan.fechaHora.add(Duration(minutes: plan.duracionMinutos));

    return Row(
      children: [
        // Fecha
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
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
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(plan.fechaHora),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3436),
                        ),
                      ),
                      Text(
                        '${timeFormat.format(plan.fechaHora)} - ${timeFormat.format(endTime)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF636E72),
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
        // Ubicación
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B9D).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFFF6B9D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.ubicacionNombre,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3436),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        plan.ciudad,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF636E72),
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

  Widget _buildDescriptionSection(PlanModel plan) {
    final maxLines = _isDescriptionExpanded ? 100 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sobre este plan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          plan.descripcion,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF636E72),
            height: 1.5,
          ),
          maxLines: maxLines,
          overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
              child: Text(
                _isDescriptionExpanded ? 'Ver menos' : 'Leer mas',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9B59B6),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMapSection(PlanModel plan) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Stack(
        children: [
          // Placeholder del mapa
          Center(
            child: Icon(
              Icons.map,
              size: 60,
              color: const Color(0xFF9B59B6).withAlpha(100),
            ),
          ),
          // Pin de ubicación
          Center(
            child: Icon(
              Icons.location_on,
              size: 40,
              color: const Color(0xFFFF6B6B),
            ),
          ),
          // Botón abrir en maps
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.navigation, color: Color(0xFF9B59B6), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Abrir en Maps',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9B59B6),
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

  Widget _buildOrganizerSection(PlanModel plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          // Foto del organizador
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF9B59B6), width: 2),
            ),
            child: ClipOval(
              child: plan.organizadorFoto.isNotEmpty
                  ? (plan.organizadorFoto.startsWith('http')
                      ? Image.network(plan.organizadorFoto, fit: BoxFit.cover)
                      : Image.memory(base64Decode(plan.organizadorFoto), fit: BoxFit.cover))
                  : Container(
                      color: const Color(0xFFE0E0E0),
                      child: const Icon(Icons.person, color: Color(0xFF636E72)),
                    ),
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
                    color: const Color(0xFF2D3436),
                  ),
                ),
                Text(
                  'Organizador',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ),
          // Rating
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB347).withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFB347), size: 16),
                const SizedBox(width: 4),
                Text(
                  plan.organizadorReputacion.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFB347),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(PlanModel plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quien va (${plan.capacidadActual} personas)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Ver todos los participantes
              },
              child: Text(
                'Ver todos',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9B59B6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Avatar stack
        SizedBox(
          height: 45,
          child: Stack(
            children: [
              ...List.generate(
                plan.participantesIds.length > 5 ? 5 : plan.participantesIds.length,
                (index) => Positioned(
                  left: index * 30.0,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: Color(0xFF9B59B6).withAlpha(50 + (index * 30)),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 24),
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
                      border: Border.all(color: Colors.white, width: 3),
                      color: const Color(0xFF636E72),
                    ),
                    child: Center(
                      child: Text(
                        '+${plan.participantesIds.length - 5}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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

  Widget _buildAffinitySection(PlanModel plan) {
    // Calcular afinidad simulada (en producción vendría del backend)
    final affinityPercentage = 85;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9B59B6).withAlpha(26),
            const Color(0xFF4ECDC4).withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9B59B6).withAlpha(50)),
      ),
      child: Row(
        children: [
          // Porcentaje
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF9B59B6), Color(0xFF4ECDC4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                '$affinityPercentage%',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
                    color: const Color(0xFF2D3436),
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
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9B59B6)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF636E72),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetails(PlanModel plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalles adicionales',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          Icons.attach_money,
          'Costo',
          plan.tipoPrecio == PlanPriceType.gratis
              ? 'Gratis'
              : '\$${plan.precio.toStringAsFixed(0)} COP',
        ),
        _buildDetailRow(
          Icons.directions,
          'Como llegar',
          'Parking disponible',
        ),
        _buildDetailRow(
          Icons.timer,
          'Duracion',
          '${(plan.duracionMinutos / 60).toStringAsFixed(0)} horas',
        ),
        _buildDetailRow(
          Icons.info_outline,
          'Requisitos',
          'Ser mayor de 18',
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9B59B6), size: 22),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF636E72),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D3436),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(PlanModel plan, bool isUserJoined, bool isOrganizer, bool isFull) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón principal
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isJoining
                  ? null
                  : () => _handleJoinLeave(plan, isUserJoined, isOrganizer),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: isUserJoined
                    ? const Color(0xFFFF6B6B)
                    : (isFull ? const Color(0xFFE0E0E0) : const Color(0xFF9B59B6)),
                disabledBackgroundColor: const Color(0xFFE0E0E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF9B59B6).withAlpha(100),
              ),
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
                              ? 'Salir del plan'
                              : (isFull ? 'Plan lleno' : 'Unirme al plan')),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // Reportar plan
          if (!isOrganizer)
            GestureDetector(
              onTap: () {
                // TODO: Reportar plan
              },
              child: Text(
                'Reportar plan',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF636E72),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleJoinLeave(PlanModel plan, bool isUserJoined, bool isOrganizer) async {
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
            const SnackBar(
              content: Text('Debes iniciar sesion'),
              backgroundColor: Color(0xFFFF6B6B),
            ),
          );
        }
        return;
      }

      if (isUserJoined) {
        await repository.leavePlan(plan.id, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Has salido del plan'),
              backgroundColor: Color(0xFFFF6B6B),
            ),
          );
        }
      } else {
        await repository.joinPlan(plan.id, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Te has unido al plan!'),
              backgroundColor: Color(0xFF4ECDC4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF6B6B),
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

/// Provider para obtener un plan en tiempo real
final planStreamProvider = StreamProvider.family<PlanModel?, String>((ref, planId) {
  return ref.watch(planRepositoryProvider).watchPlan(planId);
});
