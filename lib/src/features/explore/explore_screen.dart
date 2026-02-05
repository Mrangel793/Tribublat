import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/plans/data/plan_repository.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:myapp/src/features/plans/presentation/feed/controllers/feed_controller.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      // Navegar al feed con la busqueda activa
      ref.read(feedControllerProvider.notifier).search(query);
      // Cambiar a la pestaña de inicio (feed)
      DefaultTabController.of(context).animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explorar',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Descubre planes por categoria',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF636E72),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Barra de búsqueda funcional
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _onSearch,
                        decoration: InputDecoration(
                          hintText: 'Buscar planes, lugares, actividades...',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFFB2BEC3),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF9B59B6),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Color(0xFF636E72)),
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
                  ],
                ),
              ),
            ),
            // Título de categorías
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Categorias',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // Grid de categorías
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
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

  Widget _buildCategoryCard(BuildContext context, PlanCategoryInfo category) {
    // Obtener la categoria enum
    final planCategory = PlanCategory.values.firstWhere(
      (c) => c.name == category.id,
      orElse: () => PlanCategory.otros,
    );
    final countAsync = ref.watch(categoryCountProvider(planCategory));

    return GestureDetector(
      onTap: () {
        context.push('/explore/category/${category.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              category.color.withAlpha(200),
              category.color,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: category.color.withAlpha(100),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Emoji de fondo
            Positioned(
              right: -10,
              bottom: -10,
              child: Text(
                category.emoji,
                style: TextStyle(
                  fontSize: 60,
                  color: Colors.white.withAlpha(51),
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    category.nombre,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  countAsync.when(
                    loading: () => Text(
                      'Cargando...',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                    error: (_, __) => Text(
                      '0 planes',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                    data: (count) => Text(
                      '$count ${count == 1 ? 'plan' : 'planes'}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withAlpha(200),
                      ),
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
}
