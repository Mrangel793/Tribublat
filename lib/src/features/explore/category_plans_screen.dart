import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/plans/data/plan_repository.dart';
import 'package:myapp/src/features/plans/domain/models/plan_model.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:myapp/src/features/plans/presentation/feed/widgets/plan_card.dart';
import 'package:myapp/src/features/plans/presentation/feed/controllers/feed_controller.dart';

/// Provider para planes de una categoria especifica
final categoryPlansProvider = StreamProvider.family<List<PlanModel>, PlanCategory>((ref, category) {
  return ref.watch(planRepositoryProvider).watchPlansByCategory(category);
});

/// Pantalla de planes filtrados por categoria
class CategoryPlansScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryPlansScreen({
    super.key,
    required this.categoryId,
  });

  PlanCategory? _getCategoryFromId(String id) {
    try {
      return PlanCategory.values.firstWhere((c) => c.name == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = _getCategoryFromId(categoryId);

    if (category == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Categoria no encontrada'),
          backgroundColor: const Color(0xFF9B59B6),
        ),
        body: const Center(
          child: Text('La categoria solicitada no existe'),
        ),
      );
    }

    final categoryInfo = PlanConstants.getCategoryByEnum(category);
    final plansAsync = ref.watch(categoryPlansProvider(category));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Header con gradiente de la categoria
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: categoryInfo?.color ?? const Color(0xFF9B59B6),
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryInfo?.color ?? const Color(0xFF9B59B6),
                      (categoryInfo?.color ?? const Color(0xFF9B59B6)).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Emoji de fondo
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Text(
                        categoryInfo?.emoji ?? '📋',
                        style: TextStyle(
                          fontSize: 150,
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ),
                    // Contenido
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                categoryInfo?.emoji ?? '📋',
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              categoryInfo?.nombre ?? 'Categoria',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lista de planes
          plansAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error', style: GoogleFonts.inter()),
                  ],
                ),
              ),
            ),
            data: (plans) {
              if (plans.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(categoryInfo),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final plan = plans[index];
                      final feedController = ref.read(feedControllerProvider.notifier);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PlanCard(
                          plan: plan,
                          onTap: () => context.push('/plan/${plan.id}'),
                          onJoin: () {
                            if (feedController.isUserInPlan(plan)) {
                              feedController.leavePlan(plan.id);
                            } else {
                              feedController.joinPlan(plan.id);
                            }
                          },
                          isUserJoined: feedController.isUserInPlan(plan),
                          isInWaitingList: feedController.isUserInWaitingList(plan),
                        ),
                      );
                    },
                    childCount: plans.length,
                  ),
                ),
              );
            },
          ),
          // Espacio al final
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(PlanCategoryInfo? categoryInfo) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: (categoryInfo?.color ?? const Color(0xFF9B59B6)).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  categoryInfo?.emoji ?? '📋',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay planes de ${categoryInfo?.nombre ?? 'esta categoria'}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Se el primero en crear un plan de esta categoria',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF636E72),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
