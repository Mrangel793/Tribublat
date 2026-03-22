import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/plans/data/plan_repository.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:myapp/src/features/plans/presentation/feed/controllers/feed_controller.dart';

// Banner para acceder al directorio de espacios
Widget _buildSpacesBanner(BuildContext context) {
  return GestureDetector(
    onTap: () => context.push('/spaces'),
    child: Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: DarkFeedColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.store_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Directorio de Espacios',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Bares, cafés, restaurantes y más para tus planes',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: Colors.white, size: 16),
        ],
      ),
    ),
  );
}

/// Provider para conteo de planes por categoria
final categoryCountProvider = FutureProvider.family<int, PlanCategory>((ref, category) async {
  return ref.watch(planRepositoryProvider).getPlanCountByCategory(category);
});

/// Pantalla de explorar planes por categoría
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _isFocused = _searchFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      ref.read(feedControllerProvider.notifier).search(query);
      DefaultTabController.of(context).animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header + search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return DarkFeedColors.primaryGradient
                            .createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        'Explorar',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Descubre planes por categoria',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: DarkFeedColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Search bar
                    _buildSearchBar(),
                  ],
                ),
              ),
            ),
            // Directorio de espacios banner
            SliverToBoxAdapter(
              child: _buildSpacesBanner(context),
            ),
            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return DarkFeedColors.primaryGradient
                            .createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: const Icon(Icons.grid_view_rounded,
                          size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Categorias',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: DarkFeedColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.25,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = PlanConstants.categories[index];
                    return _buildCategoryCard(context, category);
                  },
                  childCount: PlanConstants.categories.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Search bar
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _isFocused ? DarkFeedColors.primaryGradient : null,
        border: _isFocused
            ? null
            : Border.all(color: DarkFeedColors.borderSubtle),
      ),
      padding: _isFocused ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: DarkFeedColors.cardBackground.withOpacity(0.6),
          borderRadius:
              BorderRadius.circular(_isFocused ? 14.5 : 16),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onSubmitted: _onSearch,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: DarkFeedColors.textPrimary,
          ),
          cursorColor: DarkFeedColors.gradientOrange,
          decoration: InputDecoration(
            hintText: 'Buscar planes, lugares, actividades...',
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: DarkFeedColors.textSecondary.withOpacity(0.6),
            ),
            prefixIcon: ShaderMask(
              shaderCallback: (Rect bounds) {
                return DarkFeedColors.primaryGradient.createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: const Icon(Icons.search, color: Colors.white, size: 22),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: DarkFeedColors.textSecondary, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Category card
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCategoryCard(BuildContext context, PlanCategoryInfo category) {
    final planCategory = PlanCategory.values.firstWhere(
      (c) => c.name == category.id,
      orElse: () => PlanCategory.otros,
    );
    final countAsync = ref.watch(categoryCountProvider(planCategory));

    return GestureDetector(
      onTap: () => context.push('/explore/category/${category.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: DarkFeedColors.cardBackground.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DarkFeedColors.borderSubtle),
        ),
        child: Stack(
          children: [
            // Emoji de fondo grande
            Positioned(
              right: -8,
              bottom: -8,
              child: Text(
                category.emoji,
                style: TextStyle(
                  fontSize: 56,
                  color: category.color.withOpacity(0.08),
                ),
              ),
            ),
            // Glow sutil del color de categoria
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [
                      category.color.withOpacity(0.6),
                      category.color.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji icon container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const Spacer(),
                  // Name
                  Text(
                    category.nombre,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: DarkFeedColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Count
                  countAsync.when(
                    loading: () => _buildCountText('...'),
                    error: (_, __) => _buildCountText('0 planes'),
                    data: (count) => _buildCountText(
                        '$count ${count == 1 ? 'plan' : 'planes'}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        color: DarkFeedColors.textSecondary,
      ),
    );
  }
}
