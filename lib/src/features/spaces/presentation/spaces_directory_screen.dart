import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/spaces/data/space_repository.dart';
import 'package:myapp/src/features/spaces/domain/business_space_model.dart';
import 'package:myapp/src/features/user/data/user_repository.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

class SpacesDirectoryScreen extends ConsumerStatefulWidget {
  const SpacesDirectoryScreen({super.key});

  @override
  ConsumerState<SpacesDirectoryScreen> createState() =>
      _SpacesDirectoryScreenState();
}

class _SpacesDirectoryScreenState
    extends ConsumerState<SpacesDirectoryScreen> {
  SpaceCategory? _selectedCategory;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacesAsync = ref.watch(
        spaceDirectoryProvider({'categoria': _selectedCategory}));

    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildCategoryFilter(),
            Expanded(
              child: spacesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: DarkFeedColors.gradientOrange),
                ),
                error: (e, _) =>
                    Center(child: Text('Error: $e')),
                data: (spaces) {
                  final filtered = _searchQuery.isEmpty
                      ? spaces
                      : spaces
                          .where((s) =>
                              s.nombre.toLowerCase().contains(
                                  _searchQuery.toLowerCase()) ||
                              s.descripcion.toLowerCase().contains(
                                  _searchQuery.toLowerCase()))
                          .toList();

                  if (filtered.isEmpty) return _buildEmpty();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) =>
                        _buildSpaceCard(filtered[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildRegisterButton(context),
    );
  }

  Widget? _buildRegisterButton(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return null;

    final userAsync = ref.watch(
      StreamProvider((ref) =>
          ref.watch(userRepositoryProvider).userProfileStream(currentUserId)),
    );

    final user = userAsync.valueOrNull;
    if (user == null) return null;

    // Solo negocios y admins pueden registrar espacios
    if (user.rol != UserRole.negocio && user.rol != UserRole.admin) {
      return null;
    }

    return FloatingActionButton.extended(
      onPressed: () => context.push('/spaces/register'),
      backgroundColor: DarkFeedColors.gradientViolet,
      icon: const Icon(Icons.add_business, color: Colors.white),
      label: Text('Registrar local',
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: DarkFeedColors.textPrimary, size: 20),
            onPressed: () => context.pop(),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (b) =>
                      DarkFeedColors.primaryGradient.createShader(b),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    'Directorio de Espacios',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Locales para tus planes',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: DarkFeedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: DarkFeedColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DarkFeedColors.borderSubtle),
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.inter(
              color: DarkFeedColors.textPrimary, fontSize: 14),
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Buscar espacios...',
            hintStyle: GoogleFonts.inter(
                color: DarkFeedColors.textSecondary, fontSize: 14),
            prefixIcon: const Icon(Icons.search,
                color: DarkFeedColors.textSecondary, size: 20),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(null, 'Todos'),
          ...SpaceCategory.values.map(
            (cat) => _buildCategoryChip(
                cat, BusinessSpaceModel.labelForCategory(cat)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(SpaceCategory? cat, String label) {
    final isSelected = _selectedCategory == cat;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? DarkFeedColors.primaryGradient : null,
          color: isSelected ? null : DarkFeedColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : DarkFeedColors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : DarkFeedColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceCard(BusinessSpaceModel space) {
    return GestureDetector(
      onTap: () => context.push('/spaces/${space.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: DarkFeedColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: space.esPremium
                ? DarkFeedColors.gradientOrange.withValues(alpha: 0.5)
                : DarkFeedColors.borderSubtle,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 140,
                width: double.infinity,
                color: DarkFeedColors.surface,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const Icon(Icons.store,
                        size: 56,
                        color: DarkFeedColors.borderSubtle),
                    // Badge premium
                    if (space.esPremium)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: DarkFeedColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.workspace_premium,
                                  size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Destacado',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Categoría
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          BusinessSpaceModel.labelForCategory(
                              space.categoria),
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    space.nombre,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DarkFeedColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14,
                          color: DarkFeedColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          space.direccion,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: DarkFeedColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (space.puntuacionPromedio > 0) ...[
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFFFFD700)),
                        const SizedBox(width: 3),
                        Text(
                          space.puntuacionPromedio.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: DarkFeedColors.textPrimary,
                          ),
                        ),
                        Text(
                          ' (${space.totalResenas})',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: DarkFeedColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      const Icon(Icons.event_outlined,
                          size: 14,
                          color: DarkFeedColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        '${space.totalEventos} eventos',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: DarkFeedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store_outlined,
              size: 64, color: DarkFeedColors.borderSubtle),
          const SizedBox(height: 16),
          Text(
            'No hay espacios disponibles',
            style: GoogleFonts.inter(
                fontSize: 16, color: DarkFeedColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Sé el primero en registrar tu local!',
            style: GoogleFonts.inter(
                fontSize: 13, color: DarkFeedColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
