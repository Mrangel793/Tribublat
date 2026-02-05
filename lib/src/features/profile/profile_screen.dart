import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
      backgroundColor: const Color(0xFFF5F6FA),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF9B59B6)),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error al cargar perfil', style: GoogleFonts.inter()),
            ],
          ),
        ),
        data: (user) => CustomScrollView(
          slivers: [
            // Header con foto y nombre
            _buildHeader(context, ref, user, firebaseUser),

            // Contenido
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Estadísticas
                    _buildStatsCard(user),
                    const SizedBox(height: 16),

                    // Info Básica
                    _buildInfoCard(context, user, firebaseUser),
                    const SizedBox(height: 16),

                    // Galería de fotos
                    _buildGalleryCard(context, user),
                    const SizedBox(height: 16),

                    // Intereses
                    _buildInterestsCard(context, user),
                    const SizedBox(height: 16),

                    // Energía Social
                    _buildEnergyCard(user),
                    const SizedBox(height: 16),

                    // Opciones de cuenta
                    _buildAccountOptions(context, ref, user),
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

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    UserModel? user,
    User? firebaseUser,
  ) {
    final hasPhoto = user?.foto.isNotEmpty == true;
    final photoWidget = hasPhoto
        ? Image.memory(
            base64Decode(user!.foto),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
          )
        : _buildDefaultAvatar();

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF9B59B6),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9B59B6), Color(0xFFC06BFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Foto de perfil
                Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(child: photoWidget),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => context.push('/profile/edit'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Color(0xFF9B59B6),
                          ),
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
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // Ciudad y verificación
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (user?.ciudad.isNotEmpty == true) ...[
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        user!.ciudad,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    if (user?.verificado == true) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Verificado',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Badge de rol (si no es usuario normal)
                    if (user != null && user.rol != UserRole.usuario) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: user.roleColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: user.roleColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(user.roleIcon, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              user.roleName,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white,
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
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            // TODO: Navegar a configuración
          },
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFFF3E8FF),
      child: const Icon(
        Icons.person,
        size: 50,
        color: Color(0xFF9B59B6),
      ),
    );
  }

  Widget _buildStatsCard(UserModel? user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.event,
            value: '0',
            label: 'Planes creados',
            color: const Color(0xFF9B59B6),
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.group,
            value: '0',
            label: 'Asistencias',
            color: const Color(0xFF4ECDC4),
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.star,
            value: user?.reputacion.toStringAsFixed(1) ?? '5.0',
            label: 'Reputación',
            color: const Color(0xFFFFB800),
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
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey[200],
    );
  }

  Widget _buildInfoCard(BuildContext context, UserModel? user, User? firebaseUser) {
    return _buildCard(
      title: 'Información básica',
      icon: Icons.person_outline,
      onEdit: () => context.push('/profile/edit'),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user?.email ?? firebaseUser?.email ?? '-',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.cake_outlined,
            label: 'Edad',
            value: user?.edad != null ? '${user!.edad} años' : '-',
          ),
          const Divider(height: 24),
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
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF9B59B6), size: 20),
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
                  color: Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryCard(BuildContext context, UserModel? user) {
    final photos = user?.fotosAdicionales ?? [];
    final hasMainPhoto = user?.foto.isNotEmpty == true;
    final totalPhotos = (hasMainPhoto ? 1 : 0) + photos.length;

    return _buildCard(
      title: 'Galería de fotos',
      icon: Icons.photo_library_outlined,
      subtitle: '$totalPhotos/5 fotos',
      onEdit: () => context.push('/profile/edit'),
      child: Column(
        children: [
          if (totalPhotos == 0)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Agrega fotos a tu perfil',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: totalPhotos < 5 ? totalPhotos + 1 : totalPhotos,
                itemBuilder: (context, index) {
                  // Mostrar botón de agregar al final si hay menos de 5 fotos
                  if (index == totalPhotos && totalPhotos < 5) {
                    return _buildAddPhotoButton(context);
                  }

                  // Primera foto es la principal
                  if (index == 0 && hasMainPhoto) {
                    return _buildPhotoTile(user!.foto, isMain: true);
                  }

                  // Fotos adicionales
                  final photoIndex = hasMainPhoto ? index - 1 : index;
                  if (photoIndex < photos.length) {
                    return _buildPhotoTile(photos[photoIndex]);
                  }

                  return const SizedBox();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoTile(String base64Photo, {bool isMain = false}) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isMain
            ? Border.all(color: const Color(0xFF9B59B6), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(isMain ? 10 : 12),
            child: Image.memory(
              base64Decode(base64Photo),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          if (isMain)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6),
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
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF9B59B6).withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_rounded,
              color: Color(0xFF9B59B6),
              size: 32,
            ),
            Text(
              'Agregar',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF9B59B6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsCard(BuildContext context, UserModel? user) {
    final interests = user?.intereses ?? [];

    return _buildCard(
      title: 'Mis intereses',
      icon: Icons.favorite_outline,
      subtitle: '${interests.length} seleccionados',
      onEdit: () => context.push('/profile/edit'),
      child: interests.isEmpty
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange[400], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Agrega tus intereses para recibir mejores recomendaciones de planes',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[600],
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
                final interest = InterestsConstants.getInterestById(interestId);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF9B59B6).withOpacity(0.1),
                        const Color(0xFFC06BFF).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF9B59B6).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        interest?.emoji ?? '🎯',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        interest?.name ?? interestId,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9B59B6),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildEnergyCard(UserModel? user) {
    final energy = user?.nivelEnergia ?? EnergyLevel.media;

    String emoji;
    String title;
    String description;
    Color color;

    switch (energy) {
      case EnergyLevel.baja:
        emoji = '🌙';
        title = 'Tranquilo';
        description = 'Prefieres actividades relajadas con grupos pequeños';
        color = const Color(0xFF6C5CE7);
        break;
      case EnergyLevel.media:
        emoji = '⚡';
        title = 'Equilibrado';
        description = 'Te adaptas bien a diferentes ambientes';
        color = const Color(0xFF4ECDC4);
        break;
      case EnergyLevel.alta:
        emoji = '🔥';
        title = 'Activo';
        description = 'Te encanta la acción y los grupos grandes';
        color = const Color(0xFFFF6B9D);
        break;
    }

    return _buildCard(
      title: 'Energía social',
      icon: Icons.bolt_outlined,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
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
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Medidor visual
            Column(
              children: [
                _buildEnergyDot(EnergyLevel.alta, energy, const Color(0xFFFF6B9D)),
                const SizedBox(height: 4),
                _buildEnergyDot(EnergyLevel.media, energy, const Color(0xFF4ECDC4)),
                const SizedBox(height: 4),
                _buildEnergyDot(EnergyLevel.baja, energy, const Color(0xFF6C5CE7)),
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
        color: isActive ? color : Colors.grey[300],
        boxShadow: isActive
            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]
            : null,
      ),
    );
  }

  Widget _buildAccountOptions(BuildContext context, WidgetRef ref, UserModel? user) {
    return _buildCard(
      title: 'Cuenta',
      icon: Icons.settings_outlined,
      child: Column(
        children: [
          // Opciones para negocios: Metricas de planes
          if (user?.canViewAdvancedMetrics == true) ...[
            _buildOptionTile(
              icon: Icons.analytics_outlined,
              title: 'Metricas de mis planes',
              color: const Color(0xFF00B894),
              onTap: () => context.push('/business/metrics'),
            ),
            const Divider(height: 1),
          ],
          // Opciones para admin: Panel de administracion
          if (user?.canAccessAdminPanel == true) ...[
            _buildOptionTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Panel de administracion',
              color: const Color(0xFFFF6B6B),
              onTap: () => context.push('/admin'),
            ),
            const Divider(height: 1),
          ],
          _buildOptionTile(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.lock_outline,
            title: 'Privacidad y seguridad',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.help_outline,
            title: 'Ayuda',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.logout,
            title: 'Cerrar sesion',
            color: Colors.red[400],
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
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? Colors.grey[600], size: 22),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? const Color(0xFF2D3748),
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF9B59B6), size: 22),
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
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: const Color(0xFF9B59B6),
                  onPressed: onEdit,
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout, color: Colors.red[400]),
            ),
            const SizedBox(width: 12),
            Text(
              'Cerrar sesión',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cerrar sesión',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
