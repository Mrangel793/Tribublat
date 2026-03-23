import 'dart:convert';
import 'package:myapp/src/common/widgets/base64_image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/auth/provider/auth_provider.dart';
import 'package:myapp/src/features/user/data/user_repository.dart';
import 'package:myapp/src/features/user/domain/interests_constants.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';
import 'package:myapp/src/core/permissions/user_permission_extensions.dart';

/// Provider para el perfil del usuario actual
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).userProfileStream(userId);
});

/// Pantalla de perfil del usuario
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: DarkFeedColors.gradientOrange),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: DarkFeedColors.errorRed),
              const SizedBox(height: 16),
              Text(
                'Error al cargar perfil',
                style: GoogleFonts.inter(color: DarkFeedColors.textSecondary),
              ),
            ],
          ),
        ),
        data: (user) => CustomScrollView(
          slivers: [
            _buildHeader(context, ref, user, firebaseUser),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildStatsRow(user),
                    const SizedBox(height: 20),
                    _buildInfoSection(context, user, firebaseUser),
                    const SizedBox(height: 20),
                    _buildGallerySection(context, user),
                    const SizedBox(height: 20),
                    _buildInterestsSection(context, user),
                    const SizedBox(height: 20),
                    _buildEnergySection(user),
                    const SizedBox(height: 20),
                    _buildAccountSection(context, ref, user),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Header con foto de perfil
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    UserModel? user,
    User? firebaseUser,
  ) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: DarkFeedColors.background,
      automaticallyImplyLeading: false,
      actions: [
        GestureDetector(
          onTap: () {
            // TODO: Navegar a configuracion
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF0A0A0A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Foto con borde gradiente
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        radius: 57,
                        backgroundColor: DarkFeedColors.cardBackground,
                        backgroundImage: user?.foto.isNotEmpty == true
                            ? smartImageProvider(user!.foto)
                            : null,
                        child: user?.foto.isNotEmpty != true
                            ? const Icon(Icons.person,
                                size: 50, color: DarkFeedColors.textSecondary)
                            : null,
                      ),
                    ),
                    // Boton editar foto
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => context.push('/profile/edit'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: DarkFeedColors.cardBackground,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: DarkFeedColors.borderSubtle, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 16, color: DarkFeedColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Nombre
                Text(
                  user?.nombre ?? firebaseUser?.displayName ?? 'Usuario',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: DarkFeedColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                // Ciudad + badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (user?.ciudad.isNotEmpty == true) ...[
                      const Icon(Icons.location_on,
                          color: DarkFeedColors.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        user!.ciudad,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: DarkFeedColors.textSecondary,
                        ),
                      ),
                    ],
                    if (user?.verificado == true) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: DarkFeedColors.greenEmerald.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: DarkFeedColors.greenEmerald.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified,
                                color: DarkFeedColors.greenEmerald, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Verificado',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: DarkFeedColors.greenEmerald,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (user != null && user.rol != UserRole.usuario) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: user.roleColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: user.roleColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(user.roleIcon,
                                color: user.roleColor, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              user.roleName,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: user.roleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Stats row
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStatsRow(UserModel? user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: DarkFeedColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.event,
            value: '0',
            label: 'Planes',
            color: DarkFeedColors.gradientViolet,
          ),
          Container(width: 1, height: 44, color: DarkFeedColors.borderSubtle),
          _buildStatItem(
            icon: Icons.group,
            value: '0',
            label: 'Asistencias',
            color: DarkFeedColors.greenEmerald,
          ),
          Container(width: 1, height: 44, color: DarkFeedColors.borderSubtle),
          _buildStatItem(
            icon: Icons.star_rounded,
            value: user?.reputacion.toStringAsFixed(1) ?? '5.0',
            label: 'Reputacion',
            color: const Color(0xFFFFD700),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: DarkFeedColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: DarkFeedColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Info basica
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInfoSection(
      BuildContext context, UserModel? user, User? firebaseUser) {
    return _buildCard(
      title: 'Informacion basica',
      icon: Icons.person_outline,
      onEdit: () => context.push('/profile/edit'),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user?.email ?? firebaseUser?.email ?? '-',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
                height: 1, color: DarkFeedColors.borderSubtle.withOpacity(0.5)),
          ),
          _buildInfoRow(
            icon: Icons.cake_outlined,
            label: 'Edad',
            value: user?.edad != null ? '${user!.edad} anos' : '-',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
                height: 1, color: DarkFeedColors.borderSubtle.withOpacity(0.5)),
          ),
          _buildInfoRow(
            icon: Icons.location_city_outlined,
            label: 'Ciudad',
            value: user?.ciudad.isNotEmpty == true ? user!.ciudad : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DarkFeedColors.gradientViolet.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: DarkFeedColors.gradientViolet, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: DarkFeedColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: DarkFeedColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Galeria
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGallerySection(BuildContext context, UserModel? user) {
    final photos = user?.fotosAdicionales ?? [];
    final hasMainPhoto = user?.foto.isNotEmpty == true;
    final totalPhotos = (hasMainPhoto ? 1 : 0) + photos.length;

    return _buildCard(
      title: 'Galeria de fotos',
      icon: Icons.photo_library_outlined,
      subtitle: '$totalPhotos/5 fotos',
      onEdit: () => context.push('/profile/edit'),
      child: totalPhotos == 0
          ? Container(
              height: 120,
              decoration: BoxDecoration(
                color: DarkFeedColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate,
                        size: 40, color: DarkFeedColors.textSecondary.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'Agrega fotos a tu perfil',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: DarkFeedColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: totalPhotos < 5 ? totalPhotos + 1 : totalPhotos,
                itemBuilder: (context, index) {
                  if (index == totalPhotos && totalPhotos < 5) {
                    return _buildAddPhotoButton(context);
                  }
                  if (index == 0 && hasMainPhoto) {
                    return _buildPhotoTile(user!.foto, isMain: true);
                  }
                  final photoIndex = hasMainPhoto ? index - 1 : index;
                  if (photoIndex < photos.length) {
                    return _buildPhotoTile(photos[photoIndex]);
                  }
                  return const SizedBox();
                },
              ),
            ),
    );
  }

  Widget _buildPhotoTile(String base64Photo, {bool isMain = false}) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: isMain
            ? Border.all(color: DarkFeedColors.gradientOrange, width: 2)
            : Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(isMain ? 12 : 14),
            child: Base64ImageWidget(
              base64String: base64Photo,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorWidget: Container(
                color: DarkFeedColors.surface,
                child: const Icon(Icons.broken_image,
                    color: DarkFeedColors.textSecondary),
              ),
            ),
          ),
          if (isMain)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: DarkFeedColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Principal',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/profile/edit'),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: DarkFeedColors.textSecondary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded,
                color: DarkFeedColors.textSecondary, size: 28),
            Text(
              'Agregar',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: DarkFeedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Intereses
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInterestsSection(BuildContext context, UserModel? user) {
    final interests = user?.intereses ?? [];

    return _buildCard(
      title: 'Mis intereses',
      icon: Icons.interests,
      subtitle: '${interests.length} seleccionados',
      onEdit: () => context.push('/profile/edit'),
      child: interests.isEmpty
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DarkFeedColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return DarkFeedColors.primaryGradient
                          .createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: const Icon(Icons.lightbulb_outline,
                        size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Agrega tus intereses para recibir mejores recomendaciones',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: DarkFeedColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests.map((interestId) {
                final interest =
                    InterestsConstants.getInterestById(interestId);
                return Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    gradient: DarkFeedColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                      color: DarkFeedColors.gradientOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(interest?.emoji ?? '',
                            style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Text(
                          interest?.name ?? interestId,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: DarkFeedColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Energia social
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEnergySection(UserModel? user) {
    final energy = user?.nivelEnergia ?? EnergyLevel.media;

    String emoji;
    String title;
    String description;
    Color color;

    switch (energy) {
      case EnergyLevel.baja:
        emoji = '🌙';
        title = 'Tranquilo';
        description = 'Prefieres actividades relajadas con grupos pequenos';
        color = const Color(0xFF6C5CE7);
        break;
      case EnergyLevel.media:
        emoji = '⚡';
        title = 'Equilibrado';
        description = 'Te adaptas bien a diferentes ambientes';
        color = const Color(0xFFFF8C42);
        break;
      case EnergyLevel.alta:
        emoji = '🔥';
        title = 'Activo';
        description = 'Te encanta la accion y los grupos grandes';
        color = const Color(0xFFFF4757);
        break;
    }

    return _buildCard(
      title: 'Energia social',
      icon: Icons.bolt_outlined,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: DarkFeedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Dots visuales
            Column(
              children: [
                _buildEnergyDot(
                    EnergyLevel.alta, energy, const Color(0xFFFF4757)),
                const SizedBox(height: 4),
                _buildEnergyDot(
                    EnergyLevel.media, energy, const Color(0xFFFF8C42)),
                const SizedBox(height: 4),
                _buildEnergyDot(
                    EnergyLevel.baja, energy, const Color(0xFF6C5CE7)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyDot(EnergyLevel level, EnergyLevel current, Color color) {
    final isActive = current == level;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? color : DarkFeedColors.borderSubtle,
        boxShadow: isActive
            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]
            : null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Opciones de cuenta
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAccountSection(
      BuildContext context, WidgetRef ref, UserModel? user) {
    return _buildCard(
      title: 'Cuenta',
      icon: Icons.settings_outlined,
      child: Column(
        children: [
          // Solicitar cuenta de negocio (solo para usuarios estándar)
          if (user?.rol == UserRole.usuario) ...[
            _buildOptionTile(
              icon: Icons.store_outlined,
              title: 'Registrar mi negocio',
              subtitle: 'Solicita una cuenta de negocio',
              color: DarkFeedColors.gradientViolet,
              onTap: () => context.push('/request-business'),
            ),
            Container(
                height: 1,
                color: DarkFeedColors.borderSubtle.withValues(alpha: 0.5)),
          ],
          if (user?.canViewAdvancedMetrics == true) ...[
            _buildOptionTile(
              icon: Icons.analytics_outlined,
              title: 'Metricas de mis planes',
              color: DarkFeedColors.greenEmerald,
              onTap: () => context.push('/business/metrics'),
            ),
            Container(
                height: 1, color: DarkFeedColors.borderSubtle.withValues(alpha: 0.5)),
          ],
          if (user?.canAccessAdminPanel == true) ...[
            _buildOptionTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Panel de administracion',
              color: DarkFeedColors.errorRed,
              onTap: () => context.push('/admin'),
            ),
            Container(
                height: 1, color: DarkFeedColors.borderSubtle.withOpacity(0.5)),
          ],
          _buildOptionTile(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            onTap: () {},
          ),
          Container(
              height: 1, color: DarkFeedColors.borderSubtle.withOpacity(0.5)),
          _buildOptionTile(
            icon: Icons.lock_outline,
            title: 'Privacidad y seguridad',
            onTap: () {},
          ),
          Container(
              height: 1, color: DarkFeedColors.borderSubtle.withOpacity(0.5)),
          _buildOptionTile(
            icon: Icons.help_outline,
            title: 'Ayuda',
            onTap: () {},
          ),
          Container(
              height: 1, color: DarkFeedColors.borderSubtle.withOpacity(0.5)),
          _buildOptionTile(
            icon: Icons.logout,
            title: 'Cerrar sesion',
            color: DarkFeedColors.errorRed,
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    String? subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading:
          Icon(icon, color: color ?? DarkFeedColors.textSecondary, size: 22),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? DarkFeedColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: GoogleFonts.inter(
                  fontSize: 12, color: DarkFeedColors.textSecondary))
          : null,
      trailing: Icon(Icons.chevron_right,
          color: DarkFeedColors.textSecondary.withValues(alpha: 0.5), size: 20),
      onTap: onTap,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Card reutilizable dark
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCard({
    required String title,
    required IconData icon,
    String? subtitle,
    VoidCallback? onEdit,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DarkFeedColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return DarkFeedColors.primaryGradient.createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Icon(icon, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DarkFeedColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: DarkFeedColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DarkFeedColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: DarkFeedColors.borderSubtle),
                    ),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return DarkFeedColors.primaryGradient
                            .createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: const Icon(Icons.edit_outlined,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Logout dialog
  // ═══════════════════════════════════════════════════════════════
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DarkFeedColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DarkFeedColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: DarkFeedColors.errorRed),
            ),
            const SizedBox(width: 12),
            Text(
              'Cerrar sesion',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DarkFeedColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Estas seguro que deseas cerrar sesion?',
          style: GoogleFonts.inter(color: DarkFeedColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: DarkFeedColors.textSecondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(ctx);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: DarkFeedColors.errorRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Cerrar sesion',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
